# MTF Moving Average

input AvgType = AverageType.EXPONENTIAL;
input Length = 8;
input priceclose = close;

plot AVG = MovingAverage(AvgType);
AVG.setdefaultcolor(color.yellow);

script CalcMomentum {
    input priceData = close;
    input lookbackPeriod = 14;
    
    # Calculate the change from X bars ago
    def change = priceData - priceData[lookbackPeriod];
    
    # Return the final calculation via a plot statement
    plot Result = change;
}
