function [ varargout ] = mybode( varargin )
fontName = 'Times New Roman';
if nargin == 1&&iscell(varargin{1})
    varargin = varargin{1};
end
styles = {};
if nargin == 2 && iscell(varargin{1}) && iscell(varargin{2})
    styles = varargin{2};
    varargin = varargin{1};
end
W = [];
for k=1:numel(varargin)
    [~,~,w] = bode(varargin{k});
    W = [W;w];
end
w = sort(unique(W));
MAG = zeros(numel(w),numel(varargin));
PHASE = zeros(numel(w),numel(varargin));

for k=1:numel(varargin)
    [mag,phase] = bode(varargin{k},w);
    MAG(:,k) = squeeze(mag);
    phase = squeeze(phase);
    phase = phase - round(phase(1)/360)*360;
    PHASE(:,k) = phase;
end
if nargout==0
    figure('Position',[100 100 760 570]);
    if isempty(styles)
        h1 = subplot(2,1,1);semilogx(w,20*log10(MAG), 'b-');
    else
        for itr = 1:size(MAG, 2)
            if isstr(styles{itr})
                h1 = subplot(2,1,1);semilogx(w,20*log10(MAG(:,itr)), styles{itr});
            else
                h1 = subplot(2,1,1);semilogx(w,20*log10(MAG(:,itr)), 'Color', styles{itr});
            end
            hold on
        end
        hold off
    end
    grid on
    %    xlim([w(1) w(end)]);
    ylabel('Magnitude [dB]','FontName',fontName,'FontSize',22);
    set(gca,'xticklabel',[]);
    set(gca,'Position',[0.15 0.584 0.775 0.314]);
    set(gca,'xtick',10.^(ceil(log10(w(1))):floor(log10(w(end)))));
    set( gca, 'FontName',fontName,'FontSize',20 );
    if isempty(styles)
        h2 = subplot(2,1,2);semilogx(w,PHASE,'b-');
    else
        for itr = 1:size(MAG, 2)
            if isstr(styles{itr})
                h2 = subplot(2,1,2);semilogx(w,PHASE(:,itr), styles{itr});
            else
                h2 = subplot(2,1,2);semilogx(w,PHASE(:,itr), 'Color', styles{itr});
            end
            hold on
        end
        hold off
    end
    grid on
    linkaxes([h1,h2],'x');
    set(gca,'Position',[0.15 0.19 0.775 0.314]);
    set(gca,'xtick',10.^(ceil(log10(w(1))):floor(log10(w(end)))));
    set( gca, 'FontName',fontName,'FontSize',20 );
    xlim([w(1) w(end)]);
    xlabel('Frequency [rad/s]','FontName',fontName,'FontSize',22);
    ylabel('Phase [deg]','FontName',fontName,'FontSize',22);
end
if nargout~=0
    varargout(1)={MAG};
    varargout(2)={PHASE};
    varargout(3)={w};
end
end