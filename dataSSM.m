clearvars
close all

nTraj = 6;
indTest = [1 4];
indTrain = setdiff(1:nTraj, indTest);
SSMDim = 2;
ICRadius = 0.4;

[F, M, C, K, fnl] = oscillator(3);
IC = getSSMIC(M, C, K, fnl, nTraj, ICRadius, SSMDim, 1);
% [F, IC] = parabolicSyst(nTraj, ICRadius, -0.01, 1, -0.13, [0,0,0], @(t,x) -[0;10*x(1,:).^3]);
IC = ICRadius * pickPointsOnHypersphere(nTraj, 6, 1);

observable = @(x) normrnd(1, 0.0, size(x)).*x;
tEnd = 200;
nSamp = 4000;
dt = tEnd/(nSamp-1);

xSim = integrateTrajectories(F, observable, tEnd, nSamp, nTraj, IC);

overEmbed = 0;
SSMOrder = 3;

% xData = coordinates_embedding(xSim, SSMDim, 'OverEmbedding', overEmbed);
xData = coordinates_embedding(xSim, SSMDim, 'ForceEmbedding', 1);

[V, SSMFunction, mfdInfo] = IMparametrization(xData(indTrain,:), SSMDim, SSMOrder, 'c1', 100, 'c2', 0.03);
%%
yData = getProjectedTrajs(xData, V);
plotReducedCoords(yData(indTest,:));

RRMS = getRMS(xData(indTest,:), SSMFunction, V)

xLifted = liftReducedTrajs(yData, SSMFunction);
plotReconstructedTrajectory(xData(indTest(1),:), xLifted(indTest(1),:), 2)

plotSSMWithTrajectories(xData(indTrain,:), SSMFunction, [1,2,3], V, 50, 'SSMDimension', SSMDim)
% axis equal
view(50, 30)
%% Reduced dynamics
[R,iT,N,T,Maps_info] = IMdynamics_map(yData(indTest,:), 'R_PolyOrd', SSMOrder, 'style', 'modal');

[yRec, xRec] = iterateMaps(R, yData, SSMFunction);

[reducedTrajDist, fullTrajDist] = computeRecDynErrors(yRec, xRec, yData, xData);

RMSE = mean(reducedTrajDist(indTest))
RRMSE = mean(fullTrajDist(indTest))

plotReducedCoords(yData(indTest(1),:), yRec(indTest(1),:))
plotReconstructedTrajectory(xData(indTest(1),:), xRec(indTest(1),:), 2)

computeEigenvaluesMap(Maps_info, dt)