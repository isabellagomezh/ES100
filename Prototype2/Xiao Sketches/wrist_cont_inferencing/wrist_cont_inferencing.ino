#include <Wrist_Final_Classification_inferencing.h>
#include "LSM6DS3.h"
#include <Wire.h>

// IMU
LSM6DS3 XIAOIMU(I2C_MODE, 0x6A);

#define CONVERT_G_TO_MS2 9.80665f
// #define FREQUENCY_HZ 200
// #define INTERVAL_MS (1000 / FREQUENCY_HZ)
// #define NUM_CHANNELS EI_CLASSIFIER_RAW_SAMPLES_PER_FRAME
// #define NUM_READINGS EI_CLASSIFIER_RAW_SAMPLE_COUNT
// #define NUM_CLASSES EI_CLASSIFIER_LABEL_COUNT

static bool debug_nn = false; // Set this to true to see e.g. features generated from the raw signal
static uint32_t run_inference_every_ms = 200;
static rtos::Thread inference_thread(osPriorityLow);
static float buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE] = { 0 };
static float inference_buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE];

/* Forward declaration */
void run_inference_background();

void setup() {
  Serial.begin(115200);
  while (!Serial);
  Serial.println("Edge Impulse Inferencing Demo");

    if (XIAOIMU.begin() != 0) {
    Serial.println("IMU error");
  } else {
    Serial.println("IMU OK!");
  }

  if (EI_CLASSIFIER_RAW_SAMPLES_PER_FRAME != 6) {
        ei_printf("ERR: EI_CLASSIFIER_RAW_SAMPLES_PER_FRAME should be equal to 6 (the 6 sensor axes)\n");
        return;
    }

    inference_thread.start(mbed::callback(&run_inference_background));

}

/**
 * @brief Return the sign of the number
 * 
 * @param number 
 * @return int 1 if positive (or 0) -1 if negative
 */
float ei_get_sign(float number) {
    return (number >= 0.0) ? 1.0 : -1.0;
}

/**
 * @brief      Run inferencing in the background.
 */
void run_inference_background()
{
    // wait until we have a full buffer
    delay((EI_CLASSIFIER_INTERVAL_MS * EI_CLASSIFIER_RAW_SAMPLE_COUNT) + 100);

    // This is a structure that smoothens the output result
    // With the default settings 70% of readings should be the same before classifying.
    ei_classifier_smooth_t smooth;
    ei_classifier_smooth_init(&smooth, 10 /* no. of readings */, 7 /* min. readings the same */, 0.8 /* min. confidence */, 0.3 /* max anomaly */);

    while (1) {
      // copy the buffer
      memcpy(inference_buffer, buffer, EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE * sizeof(float));

      // Turn the raw buffer in a signal which we can the classify
      signal_t signal;
      int err = numpy::signal_from_buffer(inference_buffer, EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE, &signal);
      if (err != 0) {
          ei_printf("Failed to create signal from buffer (%d)\n", err);
          return;
      }

      // Run the classifier
      ei_impulse_result_t result = { 0 };

      err = run_classifier(&signal, &result, debug_nn);
      if (err != EI_IMPULSE_OK) {
          ei_printf("ERR: Failed to run classifier (%d)\n", err);
          return;
      }

      // print the predictions
      
      // ei_printf("Predictions ");
      // ei_printf("(DSP: %d ms., Classification: %d ms., Anomaly: %d ms.)",
      //     result.timing.dsp, result.timing.classification, result.timing.anomaly);
      // ei_printf(": \n");
      // for (size_t ix = 0; ix < EI_CLASSIFIER_LABEL_COUNT; ix++) {
      //     ei_printf("    %s: %.5f\n", result.classification[ix].label, result.classification[ix].value);
      // }

      // ei_classifier_smooth_update yields the predicted label
      const char *prediction = ei_classifier_smooth_update(&smooth, &result);
      ei_printf("%s ", prediction);
      // print the cumulative results
      ei_printf(" [ ");
      for (size_t ix = 0; ix < smooth.count_size; ix++) {
          ei_printf("%u", smooth.count[ix]);
          if (ix != smooth.count_size + 1) {
              ei_printf(", ");
          }
          else {
            ei_printf(" ");
          }
      }
      ei_printf("]\n");

      delay(run_inference_every_ms);
    }

    ei_classifier_smooth_free(&smooth);
}

/**
* @brief      Get data and run inferencing
*
* @param[in]  debug  Get debug info if true
*/
void loop()
{
    while (1) {
        // Determine the next tick (and then sleep later)
        uint64_t next_tick = micros() + (EI_CLASSIFIER_INTERVAL_MS * 1000);

        // roll the buffer -6 points so we can overwrite the last one
        numpy::roll(buffer, EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE, -6);

        // read to the end of the buffer
        buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 6] = XIAOIMU.readFloatAccelX();
        buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 5] = XIAOIMU.readFloatAccelY();
        buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 4] = XIAOIMU.readFloatAccelZ();
        buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 3] = XIAOIMU.readFloatGyroX();
        buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 2] = XIAOIMU.readFloatGyroY();
        buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 1] = XIAOIMU.readFloatGyroZ();

        // for (int i = 0; i < 6; i++) {
        //     if (fabs(buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 6 + i]) > MAX_ACCEPTED_RANGE) {
        //         buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 6 + i] = ei_get_sign(buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 6 + i]) * MAX_ACCEPTED_RANGE;
        //     }
        // }

        buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 6] *= CONVERT_G_TO_MS2;
        buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 5] *= CONVERT_G_TO_MS2;
        buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE - 4] *= CONVERT_G_TO_MS2;

        // and wait for next tick
        uint64_t time_to_wait = next_tick - micros();
        delay((int)floor((float)time_to_wait / 1000.0f));
        delayMicroseconds(time_to_wait % 1000);
    }
}

#if !defined(EI_CLASSIFIER_SENSOR) || EI_CLASSIFIER_SENSOR != EI_CLASSIFIER_SENSOR_FUSION
#error "Invalid model for current sensor"
#endif
