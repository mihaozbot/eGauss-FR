function [data, trainData, testData, trueFunc, m, params, name] = loadScenario(scenarioIdx, n_C, p, testFraction)
%Load data for each scenario, always returning a trueFunc handle.

% Default stub (for real-world datasets without trueFunc)
trueFunc = @(u) NaN;

switch scenarioIdx
    case 1
        [data, trainData, testData, trueFunc, m, params, name] = getPaper1DData(n_C, p, testFraction);
    case 2
        [data, trainData, testData, trueFunc, m, params, name] = getRandomData(n_C, p, testFraction);
    case 3
        [data, trainData, testData, trueFunc, m, params, name] = getFriedman1Data(n_C, p, testFraction);
    case 4
        [data, trainData, testData, m, params, name] = getBostonHousingData(n_C, p, true, testFraction);
    case 5
        [data, trainData, testData, m, params, name] = getTreasuryData(n_C, p, true, testFraction);
    case 6
        [data, trainData, testData, m, params, name] = getWeatherIzmirData(n_C, p, true, testFraction);
    case 7
        [data, trainData, testData, m, params, name] = getMortgageData(n_C, p, true, testFraction);
    case 8
        [data, trainData, testData, m, params, name] = getCaliforniaData(n_C, p, true, testFraction);
    case 9
        [data, trainData, testData, m, params, name] = getGasSensorDriftData(n_C, p, true, testFraction);
    otherwise
        error('Invalid scenarioIdx: %d', scenarioIdx);
end

end
