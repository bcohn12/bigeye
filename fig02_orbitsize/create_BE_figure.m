if ~isfield(fig_props,'left_margin')
    fig_props.left_margin = 1.2;         %Left margin
end

if ~isfield(fig_props,'right_margin')
    fig_props.right_margin = .3;        %Right margin
end

if ~isfield(fig_props,'bottom_margin')
    fig_props.bottom_margin = 1.0;         %Bottom margin
end

if ~isfield(fig_props,'top_margin')
    fig_props.top_margin = .5;           %Top margin
end

if ~isfield(fig_props,'ml')
    fig_props.ml = 1.1;                   %Space between subplot (to the side)
end

if ~isfield(fig_props,'mt')
    fig_props.mt = 1;                   %Space between subplot (top)
end

fig_props.sub_pH = (fig_props.figH-(fig_props.bottom_margin+fig_props.top_margin+(fig_props.noYsubplots-1)*fig_props.mt))/...
    fig_props.noYsubplots;
fig_props.sub_pW = (fig_props.figW-(fig_props.left_margin+fig_props.right_margin+(fig_props.noXsubplots-1)*fig_props.ml))/...
    fig_props.noXsubplots;

hf = figure;
clf
set(hf,'units','centimeters','color',[1 1 1], 'position',[1 1 fig_props.figW fig_props.figH],...
    'PaperUnits','centimeters', 'PaperSize',[fig_props.figW fig_props.figH],'PaperPosition',[0 0 fig_props.figW fig_props.figH])