function eegdatapro_clear_figs()

main_fig = findobj('type','figure','name','EEGDataPro');
main_fig2 = findobj('type','figure','name','EEGDataPro - Create processing routine');
main_fig3 = findobj('type','figure','name','EEGDataPro - Choose processing routine');
set(main_fig,'HandleVisibility','off');
set(main_fig2,'HandleVisibility','off');
set(main_fig3,'HandleVisibility','off');
close all;
set(main_fig,'HandleVisibility','on');
set(main_fig2,'HandleVisibility','on');
set(main_fig3,'HandleVisibility','on');

end

