
load('C:\Shuting\fwMatch\data\m21_d2_vis\m21_d2_vis.mat')
load('C:\Shuting\fwMatch\data\ensembles\Core_m21_d2_vis.mat')

load('C:\Shuting\fwMatch\results\mycc.mat');

ens_coord1 = Pools_coords(:,1:2,1);
ens_coord1 = ens_coord1(sum(ens_coord1,2)~=0,:);
ens_coord2 = Pools_coords(:,1:2,2);
ens_coord2 = ens_coord2(sum(ens_coord2,2)~=0,:);

circ_sz = 100;
linew = 1;

h = figure;set(gcf,'color','w','position',[2024 497 632 484],'paperpositionmode','manual');
subplot(1,2,1)
hold on;
scatter(ens_coord1(:,1),-ens_coord1(:,2),circ_sz,mycc.red,'filled');
scatter(Coord_active(:,1),-Coord_active(:,2),circ_sz,'k','linewidth',linew)
axis off equal

subplot(1,2,2)
hold on;
scatter(ens_coord2(:,1),-ens_coord2(:,2),circ_sz,mycc.blue,'filled');
scatter(Coord_active(:,1),-Coord_active(:,2),circ_sz,'k','linewidth',linew)
axis off equal

saveas(h,'C:\Shuting\fwMatch\paper\figures\matlab_fig\1d_scatter_ensembles');
saveas(h,'C:\Shuting\fwMatch\paper\figures\matlab_fig\1d_scatter_ensembles.pdf');