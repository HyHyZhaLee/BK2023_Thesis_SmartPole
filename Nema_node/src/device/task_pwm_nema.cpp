#include "task_pwm_nema.h"

void pwm_init()
{
  // Configure LEDC Timer
  ledcSetup(LEDC_CHANEL, FREQ_HZ, RESOLUTION);

  // Attach the channel to the GPIO to be controlled
  ledcAttachPin(POLE_LED_PIN, LEDC_CHANEL);

  // Initialize fade service for smooth fading
  ledcWrite(LEDC_CHANEL, INIT_DUTY_PWM);
}

void pwm_set_duty(int dutyPercent)
{
  if (dutyPercent > 100)
  {
    dutyPercent = 100;
  }
  else if (dutyPercent < 0)
  {
    dutyPercent = 0;
  }
  int pwmDuty = map(dutyPercent, 0, 100, 0, pow(2, PWM_RESOLUTION) - 1);
  ledcWrite(PWM_CHANNEL, pwmDuty);
}

void task_pwm_light_control_init(void* pvParameters)
{
  pwm_init();

  vTaskDelete(NULL);
}