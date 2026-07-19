
# MTF Moving Average

input AvgType = AverageType.EXPONENTIAL;
input Length = 8;
input priceclose = close;

plot AVG = MovingAverage(AvgType);
AVG.setdefaultcolor(color.yellow);