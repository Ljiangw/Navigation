%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               ����˵��:EKF���˲ο�����                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ���ó�ʼ״̬
clc
clear

%��������
load('data_20181226002.mat');dt = 0.02;%��¼���ݵ�ʱ����Ϊ20ms

%���泤��
indexLimit = length(gyrox);

%�ش�ʸ��
B = [0.846358141678830;0.000944732992079314;1.02263352844190];
%�ش�ʸ����һ��
B = B/norm(B);
%�������ٶ�
g = 9.8;
%�ǶȻ���ת��
d2r = pi/180;
r2d = 180/pi;

%״̬���ݼ�¼ ��Ԫ����������ƫ�� - ��λrad [q0,q1,q2,q3,Ggrx_b,Ggry_b,Gyrz_b]
StatesLog = zeros(indexLimit,7);
%ŷ�������ݼ�¼
EulLog = zeros(indexLimit,3);
%�����ǽǶ��������ݼ�¼
DelAngLog = zeros(indexLimit,3);
%7״̬�������ݼ�¼
P1=zeros(indexLimit,1);
P2=zeros(indexLimit,1);
P3=zeros(indexLimit,1);
P4=zeros(indexLimit,1);
P5=zeros(indexLimit,1);
P6=zeros(indexLimit,1);
P7=zeros(indexLimit,1);

%�����˲��������Ǽ��ٶȼ����ݼ�¼
gyrox_filted = zeros(indexLimit,1);
gyroy_filted = zeros(indexLimit,1);
gyroz_filted = zeros(indexLimit,1);
accx_filted = zeros(indexLimit,1);
accy_filted = zeros(indexLimit,1);
accz_filted = zeros(indexLimit,1);


%% ��ʼ��׼
N = 1;
accx_average = mean(accx(1:N));
accy_average = mean(accy(1:N));
accz_average = mean(accz(1:N));
magx_average = mean(magx(1:N));
magy_average = mean(magy(1:N));
magz_average = mean(magz(1:N));

%ȷ����ʼŷ����
pitch_init = asin(accx_average / g);
roll_init = atan(accy_average / accz_average);

if magx_average>0 && magy_average==0
    yaw_init = 0;
else if magy_average<0
        yaw_init = pi/2 + atan(magx_average/magy_average);
    else if magx_average<0 && magy_average==0
            yaw_init = pi/2;
        else if magy_average>0
                yaw_init = 3*pi/2 + atan(magx_average/magy_average);
            end
        end
    end
end

%ŷ����ת��Ԫ��
EulLog(1,:) = [roll_init, pitch_init, yaw_init];
quat = EulToQuat(EulLog(1,:));
%��¼ŷ����
EulLog(1,:) = r2d*[roll_init, pitch_init, yaw_init];
%��Ԫ��ת����������
Tbn = Quat2Tbn(quat);
%��ʼ״̬��ֵ
StatesLog(1,(1:4)) = quat;
% StatesLog(1,(5:7)) = [mean(gyrox(1:300)),mean(gyroy(1:300)),mean(gyroz(1:300))];
%��ʼ�����ǽǶ�������ֵ
DelAngLog(1,:) = dt*d2r*[gyrox(1),gyroy(1),gyroz(1)];
%%�����˲��������Ǽ��ٶȼƸ�ֵ
gyrox_filted(1) = gyrox(1);
gyroy_filted(1) = gyroy(1);
gyroz_filted(1) = gyroz(1);
accx_filted(1) = accx(1);
accy_filted(1) = accy(1);
accz_filted(1) = accz(1);


%% �˲�������
%һ�׵�ͨ�˲�������
a = 0.5;

%% P���ʼ��
% Define the initial Euler angle covariance (Phi, Theta, Psi)
InitialEulerCovariance  = single([(10.0*pi/180); (10.0*pi/180); (10.0*pi/180)].^2);

% Define the transformation vector from a 321 sequence Euler rotation vector to a q0,...,q3 quaternion vector
% linearised around a level orientation (roll,pitch = 0,0)
J_eul2quat = ...
    single([[ 0.0, 0.0, 0.0]; ...
    [ 0.5, 0.0, 0.0]; ...
    [ 0.0, 0.5, 0.0]; ...
    [ 0.0, 0.0, 0.5]]);

angleCov = diag(InitialEulerCovariance);
Sigma_dAng   =  10*pi/180*dt;
% Transform the Euler angle covariances into the equivalent quaternion covariances
quatCov = J_eul2quat*angleCov*transpose(J_eul2quat);
covariance   = diag([0;0;0;0;Sigma_dAng*[0.1;0.1;0.1].^2]);
% Add the quaternion covariances
covariance(1:4,1:4)=quatCov;
P = covariance;
P1(1)=P(1,1);
P2(1)=P(2,2);
P3(1)=P(3,3);
P4(1)=P(4,4);
P5(1)=P(5,5);
P6(1)=P(6,6);
P7(1)=P(7,7);

%% Q���ʼ��
% % Allow for 0.5 deg/sec of gyro error
% daxNoise = (dt*0.2*pi/180)^2;
% dayNoise = (dt*0.2*pi/180)^2;
% dazNoise = (dt*0.2*pi/180)^2;
% % Allow for 0.05 deg/sec of gyro error
% daxNoise = (dt*0.05*pi/180)^2;
% dayNoise = (dt*0.05*pi/180)^2;
% dazNoise = (dt*0.05*pi/180)^2;
% Allow for 0.5 deg/sec of gyro error
% daxNoise = (dt*0.5*pi/180)^2;
% dayNoise = (dt*0.5*pi/180)^2;
% dazNoise = (dt*0.5*pi/180)^2;
% Allow for 0.5 deg/sec of gyro error
daxNoise = (dt*0.01*pi/180)^2;
dayNoise = (dt*0.01*pi/180)^2;
dazNoise = (dt*0.01*pi/180)^2;


%% AccR���ʼ��
% Ra = 5e-4*eye(3);
% Ra = 5e-2*eye(3);
% Ra = 5e-6*eye(3);
Ra = 1e-1*eye(3);

%% MagR���ʼ��
Rm = 9e-6*eye(3);
% Rm = 9e-4*eye(3);
% Rm = 9e-9*eye(3);

%% �����·
for index = 2 : indexLimit
    %�������Ǽ��ٶȼ����ݽ���һ�׵�ͨ�˲�
    gyrox_filted(index) = a*(gyrox(index)) + (1 - a)*gyrox_filted(index-1);
    gyroy_filted(index) = a*(gyroy(index)) + (1 - a)*gyroy_filted(index-1);
    gyroz_filted(index) = a*(gyroz(index)) + (1 - a)*gyroz_filted(index-1);
    accx_filted(index)  = a*(accx(index)) + (1 - a)*accx_filted(index-1);
    accy_filted(index)  = a*(accy(index)) + (1 - a)*accy_filted(index-1);
    accz_filted(index)  = a*(accz(index)) + (1 - a)*accz_filted(index-1);
    
    %% ״̬һ��Ԥ��
    %�Ƕ�����
    dAng = d2r * 0.5 * dt * [gyrox_filted(index) + gyrox_filted(index-1); ...
                             gyroy_filted(index) + gyroy_filted(index-1); ...
                             gyroz_filted(index) + gyroz_filted(index-1) ];
    %�Ƕ�������ȥ������ƫ��
    dAng = dAng - StatesLog(index - 1,(5:7))';
    %��ȥԲ׶���
    correctedDelAng = dAng - 1/12 * cross(DelAngLog(index-1,:)',dAng);
    %������ĽǶ�����
    DelAngLog(index,:) = dAng';
    %����ת�Ƕ�ת����Ԫ��
    deltaQuat = RotToQuat(correctedDelAng);
    %������Ԫ��
    quat = StatesLog(index-1,(1:4))';
    quat = QuatMult(quat,deltaQuat);
    %��Ԫ����һ��
    quat = NormQuat(quat);
    %����״̬
    StatesLog(index,(1:4)) = quat';
    %��Ԫ��ת����������
    Tbn = Quat2Tbn(quat);
    
    %% ����һ��Ԥ��
    dax = correctedDelAng(1);
    day = correctedDelAng(2);
    daz = correctedDelAng(3);

    q0 = quat(1);
    q1 = quat(2);
    q2 = quat(3);
    q3 = quat(4);

    dax_b = StatesLog(index,5);
    day_b = StatesLog(index,6);
    daz_b = StatesLog(index,7);

    % Predicted covariance
    F = W_calcF(dax,dax_b,day,day_b,daz,daz_b,q0,q1,q2,q3);
    Q = W_calcQ(daxNoise,dayNoise,dazNoise,q0,q1,q2,q3);
    P = F*P*transpose(F) + Q;
    % Force symmetry on the covariance matrix to prevent ill-conditioning
    % of the matrix which would cause the filter to blow-up
    P = 0.5*(P + transpose(P));
    P1(index)=P(1,1);
    P2(index)=P(2,2);
    P3(index)=P(3,3);
    P4(index)=P(4,4);
    P5(index)=P(5,5);
    P6(index)=P(6,6);
    P7(index)=P(7,7);
    
    %% �ںϼ��ٶȼ�
    if( abs(norm([accx_filted(index), accy_filted(index), accz_filted(index)]) - g) < 0.76)
        %���ٶȼ������һ��
        Za = transpose([accx_filted(index),accy_filted(index),accz_filted(index)]/norm([accx_filted(index), accy_filted(index), accz_filted(index)]));
        q0 = quat(1);
        q1 = quat(2);
        q2 = quat(3);
        q3 = quat(4);
        H_g= W_calcHa(q0,q1,q2,q3);
        varInnov = (H_g*P*H_g' + Ra);
        Kfusion = (P*H_g') / (varInnov);
        % Calculate the predicted magnetic declination
        za = Tbn'*[0 0 -1]';
        % Calculate the measurement innovation
        innovation = Za - za;
        % correct the state vector
        States = StatesLog(index,:)'+ Kfusion * innovation;
        StatesLog(index,:) = States';
        %��Ԫ����һ��
        quat = StatesLog(index,(1:4))';
        quat = NormQuat(quat);
        StatesLog(index,(1:4)) = quat';
        %���·���������
        Tbn = Quat2Tbn(quat);
        % correct the covariance P = P - K*H*P
        P = P - Kfusion*H_g*P;

        % Force symmetry on the covariance matrix to prevent ill-conditioning
        % of the matrix which would cause the filter to blow-up
        P = 0.5*(P + transpose(P));
        P1(index)=P(1,1);
        P2(index)=P(2,2);
        P3(index)=P(3,3);
        P4(index)=P(4,4);
        P5(index)=P(5,5);
        P6(index)=P(6,6);
        P7(index)=P(7,7);
    end
    
    %% �ںϴ�����
    %�����������һ��
    Zm = transpose([magx(index), magy(index), magz(index)]/norm([magx(index), magy(index), magz(index)]));
    q0 = quat(1);
    q1 = quat(2);
    q2 = quat(3);
    q3 = quat(4);

    mx = B(1);
    my = B(2);
    mz = B(3);
    H_mag = W_calcHm(mx,my,mz,q0,q1,q2,q3);
    varInnov = (H_mag*P*H_mag' + Rm);
    Kfusion = (P*H_mag') / varInnov;
    % Calculate the predicted magnetic declination
    % z = [Tbn'*[0;0;1];Tbn'*[mx;my;mz]];
    zm = Tbn'*[mx my mz]';
    % Calculate the measurement innovation
    innovation = Zm - zm ;
    % correct the state vector
    % states(1:3) = 0;
    States = StatesLog(index,:)'+ Kfusion * innovation;
    StatesLog(index,:) = States';
    %��Ԫ����һ��
    quat = StatesLog(index,(1:4))';
    quat = NormQuat(quat);
    StatesLog(index,(1:4)) = quat';
    %���·���������
    Tbn = Quat2Tbn(quat);
    % correct the covariance P = P - K*H*P
    P = P - Kfusion*H_mag*P;

    % Force symmetry on the covariance matrix to prevent ill-conditioning
    % of the matrix which would cause the filter to blow-up
    P = 0.5*(P + transpose(P));
    P1(index)=P(1,1);
    P2(index)=P(2,2);
    P3(index)=P(3,3);
    P4(index)=P(4,4);
    P5(index)=P(5,5);
    P6(index)=P(6,6);
    P7(index)=P(7,7);
    
    %% ����ŷ����
    EulLog(index,:) = r2d*QuatToEul(quat)';
end

i = 1:indexLimit;

figure
hold on, box on;
plot(i*0.02,pitch(i)', '-g.');
plot(i*0.02,EulLog(i,2)', '-r.');
legend('SBG������','��Ԫ�����Ƹ�����','Location','best');
title('PITCH');

figure
hold on, box on;
plot(i*0.02,roll(i)', '-g.');
plot(i*0.02,EulLog(i,1)', '-r.');
legend('SBG��ת��','��Ԫ�����ƹ�ת��','Location','best');
title('ROLL');

figure
hold on, box on;
plot(i*0.02,yaw(i), '-g.');
plot(i*0.02,EulLog(i,3)', 'r.');
legend('SBGƫ����','��Ԫ������ƫ����','Location','best');
title('YAW');

% figure
% hold on, box on;
% plot(i*0.02,StatesLog(i,5)', '-b.');
% title('GyroxƯ��');