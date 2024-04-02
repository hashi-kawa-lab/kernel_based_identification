close all
clear

Ts = 1/51200;
N = 10000;
u = randn(N, 1);

%% 真のシステム作成
% G1
Rp = 0.5; % 通過帯域リップル [dB]
Wp = 4400 * 2 * pi; % カットオフ周波数 [rad/s]
[b, a] = cheby1(3, Rp, Wp, 's');  % 3次のChebyshevフィルタを設計
G1 = tf(b,a);
G1 = c2d(G1,Ts);
figure                   % ボード線図をプロット
bode(G1);
grid on;
title('3次チェビシェフフィルタ')

%% 真のシステムの出力取得
t = (0:Ts:Ts*(N-1))';

y = lsim(G1,u,t);     % G1での演算

net = deepHW(1);
net.add_FIR(50, 1);

net.train(u, y, epochs=10000, lambda_kernel=0.1, lambda_theta_alpha=100);

[theta, theta_alpha] = net.get_fir_parameters();

figure, 
impulse(G1)
hold on
plot((0:size(theta{1}, 1)-1)*Ts, theta{1}/Ts)
plot((0:size(theta_alpha{1}, 1)-1)*Ts, theta_alpha{1}/Ts)
