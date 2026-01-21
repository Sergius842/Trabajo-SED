/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "canciones.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
volatile int boton_pulsado_irq = -1;
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
ADC_HandleTypeDef hadc1;

TIM_HandleTypeDef htim4;

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_ADC1_Init(void);
static void MX_TIM4_Init(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
void TocarTono(int delay, int duracion_ms)
{
    long ciclos = (duracion_ms * 1000) / (delay * 2);

    for (int k = 0; k < ciclos; k++)
    {
        HAL_GPIO_WritePin(GPIOD, GPIO_PIN_8, GPIO_PIN_SET);
        for(int x=0; x<delay*50; x++) { __NOP(); }

        HAL_GPIO_WritePin(GPIOD, GPIO_PIN_8, GPIO_PIN_RESET);
        for(int x=0; x<delay*50; x++) { __NOP(); }
    }
}
/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_ADC1_Init();
  MX_TIM4_Init();
  /* USER CODE BEGIN 2 */

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
	  /* ESTADOS*/
	    enum {ESPERA, CONFIGURACION, JUEGO, FIN};
	    int estado_actual = ESPERA;

	    int velocidad = 500;
	    int seleccion = -1;
	    int *pCancion;
	    int *pNotas;
	    int total_notas = 0;

	    while (1)
	    {
	      switch (estado_actual)
	      {
	        case ESPERA:
	            /* Parpadeo de LEDs de juego */
	            HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_9);
	            HAL_GPIO_TogglePin(GPIOE, GPIO_PIN_11);
	            HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_13);
	            HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_6);

	            /* Vidas encendidas*/
	            HAL_GPIO_WritePin(GPIOD, GPIO_PIN_0, 1);
	            HAL_GPIO_WritePin(GPIOD, GPIO_PIN_1, 1);

	            /* Lectura Potenciometro (Velocidad) */
	            HAL_ADC_Start(&hadc1);
	            if (HAL_ADC_PollForConversion(&hadc1, 10) == HAL_OK)
	            {
	                int lectura = HAL_ADC_GetValue(&hadc1);
	                velocidad = 800 - (lectura / 6);
	                if(velocidad < 50) velocidad = 50;
	            }
	            HAL_ADC_Stop(&hadc1);

	            /* Lectura botones MENU*/
	            if (HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_1) == GPIO_PIN_SET) seleccion = 0;
	            if (HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_2) == GPIO_PIN_SET) seleccion = 1;
	            if (HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_3) == GPIO_PIN_SET) seleccion = 2;
	            if (HAL_GPIO_ReadPin(GPIOC, GPIO_PIN_5) == GPIO_PIN_SET) seleccion = 3;

	            if(seleccion != -1)
	            {
	               /* Apagar LEDs antes de salir */
	               HAL_GPIO_WritePin(GPIOD, GPIO_PIN_9, 0);
	               HAL_GPIO_WritePin(GPIOE, GPIO_PIN_11, 0);
	               HAL_GPIO_WritePin(GPIOB, GPIO_PIN_13, 0);
	               HAL_GPIO_WritePin(GPIOC, GPIO_PIN_6, 0);
	               estado_actual = CONFIGURACION;
	            }
	            HAL_Delay(100);
	            break;

	        case CONFIGURACION:
	            HAL_GPIO_WritePin(GPIOD, GPIO_PIN_8, 1);
	            HAL_Delay(100);
	            HAL_GPIO_WritePin(GPIOD, GPIO_PIN_8, 0);
	            HAL_Delay(500);

	            if(seleccion == 0) { pCancion = c_cumple; pNotas = n_cumple; total_notas = t_cumple; }
	            else if(seleccion == 1) { pCancion = c_estrella; pNotas = n_estrella; total_notas = t_estrella; }
	            else if(seleccion == 2) { pCancion = c_starwars; pNotas = n_starwars; total_notas = t_starwars; }
	            else { pCancion = c_alegria; pNotas = n_alegria; total_notas = t_alegria; }

	            estado_actual = JUEGO;
	            break;

	        case JUEGO:
	                  int vidas = 2; /* Reiniciamos vidas */

	                  /* Bucle principal de la cancion */
	                  for(int i = 0; i < total_notas; i++)
	                  {
	                    /* 1. Actualizacion de velocidad */
	                    HAL_ADC_Start(&hadc1);
	                    if (HAL_ADC_PollForConversion(&hadc1, 10) == HAL_OK)
	                    {
	                        int lectura = HAL_ADC_GetValue(&hadc1);
	                        velocidad = 800 - (lectura / 6);
	                        if(velocidad < 50) velocidad = 50;
	                    }
	                    HAL_ADC_Stop(&hadc1);

	                    int carril = pCancion[i];

	                    int fallo_cometido = 0;

	                    /*Reseteamos pulsaciones AL PRINCIPIO de la nota */
	                    boton_pulsado_irq = -1;

	                    /* Encendemos LEDs Arriba */
	                    if(carril == 0) HAL_GPIO_WritePin(GPIOD, GPIO_PIN_11, 1);
	                    if(carril == 1) HAL_GPIO_WritePin(GPIOE, GPIO_PIN_13, 1);
	                    if(carril == 2) HAL_GPIO_WritePin(GPIOB, GPIO_PIN_15, 1);
	                    if(carril == 3) HAL_GPIO_WritePin(GPIOC, GPIO_PIN_9, 1);

	                    /* Deteccion del fallo*/
	                    for(int w = 0; w < velocidad; w += 10)
	                    {
	                        HAL_Delay(10);
	                        /* Fallo por pulsar pronto*/
	                        if(boton_pulsado_irq != -1)
	                        {
	                            fallo_cometido = 1;
	                            break;
	                        }
	                    }

	                    /* Apagamos LEDs Arriba */
	                    HAL_GPIO_WritePin(GPIOD, GPIO_PIN_11, 0);
	                    HAL_GPIO_WritePin(GPIOE, GPIO_PIN_13, 0);
	                    HAL_GPIO_WritePin(GPIOB, GPIO_PIN_15, 0);
	                    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_9, 0);

	                    /* Si fallaste arriba, saltamos al final directamente */
	                    if(fallo_cometido) goto GESTION_FALLO;


	                    /* Encendemos LEDs Medio */
	                    if(carril == 0) HAL_GPIO_WritePin(GPIOD, GPIO_PIN_10, 1);
	                    if(carril == 1) HAL_GPIO_WritePin(GPIOE, GPIO_PIN_12, 1);
	                    if(carril == 2) HAL_GPIO_WritePin(GPIOB, GPIO_PIN_14, 1);
	                    if(carril == 3) HAL_GPIO_WritePin(GPIOC, GPIO_PIN_8, 1);

	                    /* Espera vigilada */
	                    for(int w = 0; w < velocidad; w += 10)
	                    {
	                        HAL_Delay(10);
	                        /* Fallo de nuevo */
	                        if(boton_pulsado_irq != -1)
	                        {
	                            fallo_cometido = 1;
	                            break;
	                        }
	                    }

	                    /* Apagamos LEDs Medio */
	                    HAL_GPIO_WritePin(GPIOD, GPIO_PIN_10, 0);
	                    HAL_GPIO_WritePin(GPIOE, GPIO_PIN_12, 0);
	                    HAL_GPIO_WritePin(GPIOB, GPIO_PIN_14, 0);
	                    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_8, 0);

	                    if(fallo_cometido) goto GESTION_FALLO;


	                    /* Encendemos LEDs Meta */
	                    if(carril == 0) HAL_GPIO_WritePin(GPIOD, GPIO_PIN_9, 1);
	                    if(carril == 1) HAL_GPIO_WritePin(GPIOE, GPIO_PIN_11, 1);
	                    if(carril == 2) HAL_GPIO_WritePin(GPIOB, GPIO_PIN_13, 1);
	                    if(carril == 3) HAL_GPIO_WritePin(GPIOC, GPIO_PIN_6, 1);

	                    int ha_acertado_en_meta = 0;

	                    for(int t = 0; t < 50; t++)
	                    {
	                      if(boton_pulsado_irq != -1)
	                      {
	                          /* Si pulsa, comprobamos si es el correcto */
	                          if(carril == boton_pulsado_irq)
	                          {
	                              ha_acertado_en_meta = 1;
	                              break;
	                          }
	                          else
	                          {
	                              /* Fallo si pulso el boton incorrecto*/
	                              fallo_cometido = 1;
	                              break;
	                          }
	                      }
	                      HAL_Delay(10);
	                    }

	                    /* Apagar LEDs Meta */
	                    HAL_GPIO_WritePin(GPIOD, GPIO_PIN_9, 0);
	                    HAL_GPIO_WritePin(GPIOE, GPIO_PIN_11, 0);
	                    HAL_GPIO_WritePin(GPIOB, GPIO_PIN_13, 0);
	                    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_6, 0);

	                    /* Si se acabo el tiempo y no pulso nada -> FALLO */
	                    if(ha_acertado_en_meta == 0 && fallo_cometido == 0)
	                    {
	                        fallo_cometido = 1;
	                    }


	                    if(ha_acertado_en_meta == 1)
	                    {
	                        /* Acierto */
	                        int frecuencia = 300000 / pNotas[i];
	                        __HAL_TIM_SET_AUTORELOAD(&htim4, frecuencia);
	                        __HAL_TIM_SET_COMPARE(&htim4, TIM_CHANNEL_1, frecuencia / 4);
	                        __HAL_TIM_SET_COUNTER(&htim4, 0);
	                        HAL_TIM_PWM_Start(&htim4, TIM_CHANNEL_1);
	                        HAL_Delay(120);
	                        HAL_TIM_PWM_Stop(&htim4, TIM_CHANNEL_1);

	                        /* Seguimos al siguiente bucle (siguiente nota) */
	                        continue;
	                    }

	                    /* Etiqueta para saltar aqui si fallamos pronto */
	                    GESTION_FALLO:

	                    if(fallo_cometido == 1)
	                    {
	                        /* Fallo*/
	                        vidas--;

	                        if(vidas == 1)
	                        {
	                            HAL_GPIO_WritePin(GPIOD, GPIO_PIN_1, 0); /* Apagar vida 2 */
	                        }
	                        else if(vidas == 0)
	                        {
	                            HAL_GPIO_WritePin(GPIOD, GPIO_PIN_0, 0); /* Apagar vida 1 */

	                            /* Sonido GAME OVER */
	                            __HAL_TIM_SET_AUTORELOAD(&htim4, 5000);
	                            __HAL_TIM_SET_COMPARE(&htim4, TIM_CHANNEL_1, 2500);
	                            HAL_TIM_PWM_Start(&htim4, TIM_CHANNEL_1);
	                            HAL_Delay(1000);
	                            HAL_TIM_PWM_Stop(&htim4, TIM_CHANNEL_1);

	                            break;
	                        }
	                    }

	                    HAL_Delay(10);
	                  } /* Fin del bucle for */

	                  /* Limpieza final */
	                  HAL_GPIO_WritePin(GPIOD, GPIO_PIN_0, 0);
	                  HAL_GPIO_WritePin(GPIOD, GPIO_PIN_1, 0);
	                  HAL_GPIO_WritePin(GPIOD, GPIO_PIN_11, 0); HAL_GPIO_WritePin(GPIOD, GPIO_PIN_10, 0); HAL_GPIO_WritePin(GPIOD, GPIO_PIN_9, 0);
	                  HAL_GPIO_WritePin(GPIOE, GPIO_PIN_13, 0); HAL_GPIO_WritePin(GPIOE, GPIO_PIN_12, 0); HAL_GPIO_WritePin(GPIOE, GPIO_PIN_11, 0);
	                  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_15, 0); HAL_GPIO_WritePin(GPIOB, GPIO_PIN_14, 0); HAL_GPIO_WritePin(GPIOB, GPIO_PIN_13, 0);
	                  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_9, 0); HAL_GPIO_WritePin(GPIOC, GPIO_PIN_8, 0); HAL_GPIO_WritePin(GPIOC, GPIO_PIN_6, 0);

	                  estado_actual = FIN;
	                  break;

	        case FIN:
	            seleccion = -1;
	            HAL_Delay(2000);
	            estado_actual = ESPERA;
	            break;
	      }
	    }
 }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
  RCC_OscInitStruct.PLL.PLLM = 8;
  RCC_OscInitStruct.PLL.PLLN = 50;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV4;
  RCC_OscInitStruct.PLL.PLLQ = 7;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief ADC1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_ADC1_Init(void)
{

  /* USER CODE BEGIN ADC1_Init 0 */

  /* USER CODE END ADC1_Init 0 */

  ADC_ChannelConfTypeDef sConfig = {0};

  /* USER CODE BEGIN ADC1_Init 1 */

  /* USER CODE END ADC1_Init 1 */

  /** Configure the global features of the ADC (Clock, Resolution, Data Alignment and number of conversion)
  */
  hadc1.Instance = ADC1;
  hadc1.Init.ClockPrescaler = ADC_CLOCK_SYNC_PCLK_DIV2;
  hadc1.Init.Resolution = ADC_RESOLUTION_12B;
  hadc1.Init.ScanConvMode = DISABLE;
  hadc1.Init.ContinuousConvMode = DISABLE;
  hadc1.Init.DiscontinuousConvMode = DISABLE;
  hadc1.Init.ExternalTrigConvEdge = ADC_EXTERNALTRIGCONVEDGE_NONE;
  hadc1.Init.ExternalTrigConv = ADC_SOFTWARE_START;
  hadc1.Init.DataAlign = ADC_DATAALIGN_RIGHT;
  hadc1.Init.NbrOfConversion = 1;
  hadc1.Init.DMAContinuousRequests = DISABLE;
  hadc1.Init.EOCSelection = ADC_EOC_SINGLE_CONV;
  if (HAL_ADC_Init(&hadc1) != HAL_OK)
  {
    Error_Handler();
  }

  /** Configure for the selected ADC regular channel its corresponding rank in the sequencer and its sample time.
  */
  sConfig.Channel = ADC_CHANNEL_11;
  sConfig.Rank = 1;
  sConfig.SamplingTime = ADC_SAMPLETIME_3CYCLES;
  if (HAL_ADC_ConfigChannel(&hadc1, &sConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN ADC1_Init 2 */

  /* USER CODE END ADC1_Init 2 */

}

/**
  * @brief TIM4 Initialization Function
  * @param None
  * @retval None
  */
static void MX_TIM4_Init(void)
{

  /* USER CODE BEGIN TIM4_Init 0 */

  /* USER CODE END TIM4_Init 0 */

  TIM_ClockConfigTypeDef sClockSourceConfig = {0};
  TIM_MasterConfigTypeDef sMasterConfig = {0};
  TIM_OC_InitTypeDef sConfigOC = {0};

  /* USER CODE BEGIN TIM4_Init 1 */

  /* USER CODE END TIM4_Init 1 */
  htim4.Instance = TIM4;
  htim4.Init.Prescaler = 10;
  htim4.Init.CounterMode = TIM_COUNTERMODE_UP;
  htim4.Init.Period = 1000;
  htim4.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
  htim4.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
  if (HAL_TIM_Base_Init(&htim4) != HAL_OK)
  {
    Error_Handler();
  }
  sClockSourceConfig.ClockSource = TIM_CLOCKSOURCE_INTERNAL;
  if (HAL_TIM_ConfigClockSource(&htim4, &sClockSourceConfig) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_TIM_PWM_Init(&htim4) != HAL_OK)
  {
    Error_Handler();
  }
  sMasterConfig.MasterOutputTrigger = TIM_TRGO_RESET;
  sMasterConfig.MasterSlaveMode = TIM_MASTERSLAVEMODE_DISABLE;
  if (HAL_TIMEx_MasterConfigSynchronization(&htim4, &sMasterConfig) != HAL_OK)
  {
    Error_Handler();
  }
  sConfigOC.OCMode = TIM_OCMODE_PWM1;
  sConfigOC.Pulse = 0;
  sConfigOC.OCPolarity = TIM_OCPOLARITY_HIGH;
  sConfigOC.OCFastMode = TIM_OCFAST_DISABLE;
  if (HAL_TIM_PWM_ConfigChannel(&htim4, &sConfigOC, TIM_CHANNEL_1) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN TIM4_Init 2 */

  /* USER CODE END TIM4_Init 2 */
  HAL_TIM_MspPostInit(&htim4);

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  /* USER CODE BEGIN MX_GPIO_Init_1 */

  /* USER CODE END MX_GPIO_Init_1 */

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOE_CLK_ENABLE();
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOE, CS_I2C_SPI_Pin|LED_NARANJA_1_Pin|LED_NARANJA_2_Pin|LED_NARANJA_3_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(OTG_FS_PowerSwitchOn_GPIO_Port, OTG_FS_PowerSwitchOn_Pin, GPIO_PIN_SET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOB, LED_ROJO_1_Pin|LED_ROJO_2_Pin|LED_ROJO_3_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOD, LED_AMARILLO_1_Pin|LED_AMARILLO_2_Pin|LED_AMARILLO_3_Pin|LD3_Pin
                          |LD5_Pin|LD6_Pin|VIDA_2_Pin|VIDA_1_Pin
                          |Audio_RST_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOC, LED_VERDE_1_Pin|LED_VERDE_2_Pin|LED_VERDE_3_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pins : CS_I2C_SPI_Pin LED_NARANJA_1_Pin LED_NARANJA_2_Pin LED_NARANJA_3_Pin */
  GPIO_InitStruct.Pin = CS_I2C_SPI_Pin|LED_NARANJA_1_Pin|LED_NARANJA_2_Pin|LED_NARANJA_3_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOE, &GPIO_InitStruct);

  /*Configure GPIO pins : OTG_FS_PowerSwitchOn_Pin LED_VERDE_1_Pin LED_VERDE_2_Pin LED_VERDE_3_Pin */
  GPIO_InitStruct.Pin = OTG_FS_PowerSwitchOn_Pin|LED_VERDE_1_Pin|LED_VERDE_2_Pin|LED_VERDE_3_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pin : PDM_OUT_Pin */
  GPIO_InitStruct.Pin = PDM_OUT_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF5_SPI2;
  HAL_GPIO_Init(PDM_OUT_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pin : B1_Pin */
  GPIO_InitStruct.Pin = B1_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(B1_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : BUTTON_1_Pin BUTTON_2_Pin BUTTON_3_Pin */
  GPIO_InitStruct.Pin = BUTTON_1_Pin|BUTTON_2_Pin|BUTTON_3_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pin : I2S3_WS_Pin */
  GPIO_InitStruct.Pin = I2S3_WS_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF6_SPI3;
  HAL_GPIO_Init(I2S3_WS_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : SPI1_SCK_Pin SPI1_MISO_Pin SPI1_MOSI_Pin */
  GPIO_InitStruct.Pin = SPI1_SCK_Pin|SPI1_MISO_Pin|SPI1_MOSI_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF5_SPI1;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pin : BUTTON_4_Pin */
  GPIO_InitStruct.Pin = BUTTON_4_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  HAL_GPIO_Init(BUTTON_4_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pin : BOOT1_Pin */
  GPIO_InitStruct.Pin = BOOT1_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(BOOT1_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pin : CLK_IN_Pin */
  GPIO_InitStruct.Pin = CLK_IN_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF5_SPI2;
  HAL_GPIO_Init(CLK_IN_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : LED_ROJO_1_Pin LED_ROJO_2_Pin LED_ROJO_3_Pin */
  GPIO_InitStruct.Pin = LED_ROJO_1_Pin|LED_ROJO_2_Pin|LED_ROJO_3_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pins : LED_AMARILLO_1_Pin LED_AMARILLO_2_Pin LED_AMARILLO_3_Pin LD3_Pin
                           LD5_Pin LD6_Pin VIDA_2_Pin VIDA_1_Pin
                           Audio_RST_Pin */
  GPIO_InitStruct.Pin = LED_AMARILLO_1_Pin|LED_AMARILLO_2_Pin|LED_AMARILLO_3_Pin|LD3_Pin
                          |LD5_Pin|LD6_Pin|VIDA_2_Pin|VIDA_1_Pin
                          |Audio_RST_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOD, &GPIO_InitStruct);

  /*Configure GPIO pins : I2S3_MCK_Pin I2S3_SCK_Pin I2S3_SD_Pin */
  GPIO_InitStruct.Pin = I2S3_MCK_Pin|I2S3_SCK_Pin|I2S3_SD_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF6_SPI3;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pin : VBUS_FS_Pin */
  GPIO_InitStruct.Pin = VBUS_FS_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(VBUS_FS_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : OTG_FS_ID_Pin OTG_FS_DM_Pin OTG_FS_DP_Pin */
  GPIO_InitStruct.Pin = OTG_FS_ID_Pin|OTG_FS_DM_Pin|OTG_FS_DP_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF10_OTG_FS;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pin : OTG_FS_OverCurrent_Pin */
  GPIO_InitStruct.Pin = OTG_FS_OverCurrent_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(OTG_FS_OverCurrent_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : Audio_SCL_Pin Audio_SDA_Pin */
  GPIO_InitStruct.Pin = Audio_SCL_Pin|Audio_SDA_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_OD;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF4_I2C1;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /* EXTI interrupt init*/
  HAL_NVIC_SetPriority(EXTI1_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI1_IRQn);

  HAL_NVIC_SetPriority(EXTI2_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI2_IRQn);

  HAL_NVIC_SetPriority(EXTI3_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI3_IRQn);

  HAL_NVIC_SetPriority(EXTI9_5_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI9_5_IRQn);

  /* USER CODE BEGIN MX_GPIO_Init_2 */

  /* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
	  {
	      /* Filtro anti-rebotes por software (200ms) */
	      static uint32_t ultimo_tiempo = 0;
	      uint32_t tiempo_actual = HAL_GetTick();

	      if (tiempo_actual - ultimo_tiempo < 200)
	      {
	          return; /* Ignorar pulsacion (rebote) */
	      }

	      ultimo_tiempo = tiempo_actual;

	      /* Actualizamos variable global segun el boton pulsado */
	      if(GPIO_Pin == GPIO_PIN_1) boton_pulsado_irq = 0;      /* Boton Amarillo */
	      else if(GPIO_Pin == GPIO_PIN_2) boton_pulsado_irq = 1; /* Boton Naranja */
	      else if(GPIO_Pin == GPIO_PIN_3) boton_pulsado_irq = 2; /* Boton Rojo */
	      else if(GPIO_Pin == GPIO_PIN_5) boton_pulsado_irq = 3; /* Boton Blanco */
	  }
/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
