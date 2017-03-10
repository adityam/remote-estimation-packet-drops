import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

sns.set_style("white")

def adjustFigAspect(fig,aspect=1):
    '''
    Adjust the subplot parameters so that the figure has the correct
    aspect ratio.
    '''
    xsize,ysize = fig.get_size_inches()
    minsize = min(xsize,ysize)
    xlim = .4*minsize/xsize
    ylim = .4*minsize/ysize
    if aspect < 1:
        xlim *= aspect
    else:
        ylim /= aspect
    fig.subplots_adjust(left=.5-xlim,
                        right=.5+xlim,
                        bottom=.5-ylim,
                        top=.5+ylim)

def plotTimeSeries(case, packetDropRate, parVec, betaVec, iterLimit=None):
    for b in betaVec:
        plt.clf()
        fig = plt.figure()
        for i, l in enumerate(parVec):
            if case == "constrained":
                labelText = r'$\alpha = $'
                df = pd.read_table("output/sa_constrained__parameter_" + str(l) + 
                                      "__discount_" + str(b) + 
                                      "__dropProb_" + str(packetDropRate) + ".tsv")
                if iterLimit:
                    df = df[:iterLimit]
            elif case == "costly":
                labelText = r'$\lambda = $'
                df = pd.read_table("output/sa_costly__parameter_" + str(l) + 
                                      "__discount_" + str(b) + 
                                      "__dropProb_" + str(packetDropRate) + ".tsv")
                if iterLimit:
                    df = df[:iterLimit]
            mean = df['mean'].values
            meanPlus = df['upper'].values
            meanMinus = df['lower'].values
            adjustFigAspect(fig,aspect=1.75)
            ax = fig.add_subplot(111)
            sns.despine()
            ax.plot(meanPlus, color='blue', lw = 0.5) # instead of "lightblue"
            ax.plot(meanMinus, color='blue', lw = 0.5) # instead of "lightblue"
            ax.plot(mean, color='black', lw = 0.5) # instead of "darkblue"
            ax.fill_between(range(len(mean)),meanPlus, meanMinus,facecolor='lightgrey', interpolate=True)
            sns.set_context("paper", font_scale=0.9)                                                  
            plt.figure(figsize=(3.1, 3))
            ax.set_xlim(0,len(mean))
            if case == "constrained":
                ax.set_ylim(0,3.5)
                x_loc = int(3*len(mean)/4)
                y_loc = pd.np.mean(meanPlus[-10:])+0.1
                #y_loc = int(mean[x_loc]+min(1.0,mean[x_loc]/2.0))
            else:
                ax.set_ylim(0,13)
                x_loc = int(3*len(mean)/4)
                y_loc = pd.np.mean(meanPlus[-10:])+0.15
                #y_loc = int(mean[x_loc]+min(0.8,mean[x_loc]/2.0))
            
            
            ax.text(x_loc, y_loc , labelText + str(l), fontsize=8)
            ax.set_xlabel('Iterations')
            ax.set_ylabel('Threshold')
        fig.savefig(case + "_p_d_" + str(packetDropRate) + "_beta_" + str(b) + ".pdf")


plotTimeSeries('costly', 0.3, [100.0, 500.0, 700], [0.9])
plotTimeSeries('costly', 0.3, [100.0, 500.0, 700], [1.0])
#plotTimeSeries('constrained', 0.3, [0.1, 0.3, 0.5], [0.9])
#plotTimeSeries('constrained', 0.3, [0.1, 0.3, 0.5], [1.0])
