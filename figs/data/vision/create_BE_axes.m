function ha = create_axes(plotnoX,plotnoY,fig_props)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Custom subplot function
%%
%% Title                : A massive increase in visual range preceded the origin of terrestrial vertebrates
%% Authors              : Ugurcan Mugan, Malcolm A. MacIver
%% Authors' Affiliation : Northwestern University
%% DOI for code: 10.5281/zenodo.239228, CC by 
%% January 2017
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ha = axes('unit','centimeters','Position',[fig_props.left_margin+(fig_props.noXsubplots-plotnoX)*fig_props.sub_pW+...
%     (fig_props.noXsubplots-plotnoX)*fig_props.ml,fig_props.bottom_margin+(fig_props.noYsubplots-plotnoY)*fig_props.sub_pH+...
%     (fig_props.noYsubplots-plotnoY)*fig_props.mt, fig_props.sub_pW, fig_props.sub_pH],'FontSize',8,'Box','off');

ha = axes('unit','centimeters','Position',[fig_props.left_margin+(plotnoX-1)*fig_props.sub_pW+...
    (plotnoX-1)*fig_props.ml,fig_props.bottom_margin+(fig_props.noYsubplots-plotnoY)*fig_props.sub_pH+...
    (fig_props.noYsubplots-plotnoY)*fig_props.mt, fig_props.sub_pW, fig_props.sub_pH],'FontSize',8,'Box','off',...
    'fontname','helvetica');