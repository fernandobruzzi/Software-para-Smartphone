{\rtf1\ansi\ansicpg1252\cocoartf2870
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 import 'dart:io';\
\
void main() \{\
  final input = stdin.readLineSync();\
\
  if (input == null || input.isEmpty) \{\
    print("Entrada vazia!");\
    return;\
  \}\
\
  final num = int.tryParse(input);\
\
  if (num != null) \{\
    final resultado = isPrime(num);\
    print(resultado);\
  \} else if (double.tryParse(input) != null) \{\
    print("N\'e3o \'e9 inteiro!");\
  \} else if(input.contains(','))\{\
    print("Formato num\'e9rico inv\'e1lido!");    \
  \}\
  else \{\
    print("N\'e3o \'e9 um n\'famero!");\
  \}\
\
  return;\
\}\
\
String isPrime(int num) \{\
  if (num < 0) return ("N\'famero negativo!");\
  if (num <= 1) return ("N\'e3o \'e9 primo!");\
\
  for (int i = 2; i < num; i++) \{\
    if (num % i == 0) \{\
      return ("N\'e3o \'e9 primo!");\
    \}\
  \}\
  return ("\'c9 primo!");\
\}}