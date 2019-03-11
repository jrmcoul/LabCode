function [xaxcells, xaxbeh] = plot_dF_vel(dfftrace, behavior, time)

    %plot cells and velocity with time (s) as x axis
    xaxcells = linspace(0, time, length(dfftrace))';
    xaxbeh = linspace(0, time, length(behavior))';
    subplot(2,1,2)
    plot(xaxbeh,behavior)
    title('velocity')
    subplot(2,1,1)
    title('dF/F')
    plot(xaxcells,dfftrace)
    hold on
    
end

