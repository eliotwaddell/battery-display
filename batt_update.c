#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "batt.h"



int batt_update()
{
  batt_t batt = {.volts=-100, .percent=-1, .mode=-1};//battery exclusively for batt_update
  int result = set_batt_from_ports(&batt);
  if(result!=0)
  {
    return 1;//check for failure
  }
  set_display_from_batt(batt, &BATT_DISPLAY_PORT);//this function only returns zero, as specified in problem
  return 0;
}

int set_batt_from_ports(batt_t *batt)//volts, percent and mode
{
  if(BATT_VOLTAGE_PORT < 0)//something is wrong lol
  {
    return 1;
  }
  batt->volts = BATT_VOLTAGE_PORT;//self explanatory, in millivolts
  if(batt->volts>3800)//to avoid char overflow, automatically sets anything above 3800v to 100%
  {
    batt->percent=100;
  }
  else//percentage is calculated based on given formula
  {
    batt->percent = (BATT_VOLTAGE_PORT - 3000) / 8;
  }
  if(batt->percent<0)//this would happen if voltage was below 3000
  {
    batt->percent = 0;
  }
  batt->mode = BATT_STATUS_PORT & 0b1;//checks to see if mode is set to percent or voltage. bitwise &'s the first bit of B_S_P and sets mode to result'
  return 0;
}

int set_display_from_batt(batt_t batt, int *display)
{
  *display = 0;//initialize display to all zeros
  int digits[10];//digit representations in binary
  digits[0] = 0b0111111;
  digits[1] = 0b0000011;
  digits[2] = 0b1101101;
  digits[3] = 0b1100111;
  digits[4] = 0b1010011;
  digits[5] = 0b1110110;
  digits[6] = 0b1111110;
  digits[7] = 0b0100011;
  digits[8] = 0b1111111;
  digits[9] = 0b1110111;
  int left, middle, right, disp_value;
  if(batt.mode){//disp_value represents the actual value to be printed
    disp_value = batt.percent;
  }
  else
  {
    disp_value = (batt.volts+5)/10;//only have 3 slots for display, this rounds the voltage.
  }
  right = disp_value%10;//iterates through each digit, chopping down disp_value until all digits are in their own category
  disp_value/=10;//once the modulus is assigned, the disp_value is shrunken by one order of magnitude, repeated until it is gone
  middle = disp_value%10;
  disp_value/=10;
  left = disp_value%10;
  if(left)//leftmost digit doesnt equal zero
  {//bitwise or is used to assign bits, if there are more than one digits, bits are shifted by 7 to make room for new bits
    *display |= digits[left];
    *display = *display << 7;
    *display |= digits[middle];
    *display = *display << 7;
    *display |= digits[right];
  }
  else if (middle)//if left does equal zero but there exists a middle
  {
    *display |= digits[middle];
    *display = *display << 7;
    *display |= digits[right];
  }
  else//if there only exists a right
  {
    *display |= digits[right];
  }
  if(batt.mode)//changes bit that determines to display % or V
  {
    *display |= 0b1 << 23;//%
  }
  else
  {
    *display |= 0b1 << 22;//V
    *display |= 0b1 << 21;//decimal place bit
  }
  if(batt.percent>=90)//battery bar is full
  {
    *display |= 0b1 << 24;
    *display |= 0b1 << 25;
    *display |= 0b1 << 26;
    *display |= 0b1 << 27;
    *display |= 0b1 << 28;
  }
  else if(batt.percent>=70)//each conditional is for a different "range" of battery percents
  {
    *display |= 0b1 << 25;
    *display |= 0b1 << 26;
    *display |= 0b1 << 27;
    *display |= 0b1 << 28;
  }
  else if(batt.percent>=50)
  {
    *display |= 0b1 << 26;
    *display |= 0b1 << 27;
    *display |= 0b1 << 28;
  }
  else if(batt.percent>=30)
  {
    *display |= 0b1 << 27;
    *display |= 0b1 << 28;
  }
  else if(batt.percent>=5)
  {
    *display |= 0b1 << 28;
  }
  return 0;
}
