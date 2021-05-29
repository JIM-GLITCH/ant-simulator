import subprocess
mapnumber=4
antComAlgorithm=1
numAnts=100
mapMaxX =160
mapMaxY =320
trial=1
TEST='searchmap'
def run_one_test(trial):
    print("map {} algrithm {} trial {}: running..".format(mapnumber,antComAlgorithm,trial))
    taskFinishedTime=subprocess.call(['love','./', str(mapnumber),str(antComAlgorithm),str(numAnts),str(mapMaxX),str(mapMaxY),TEST,str(trial) ], shell=True)
    # with open("map{}_algorithm{}_ants{}.txt".format(mapnumber,antComAlgorithm,numAnts),'a') as f:
    #     f.write('{}\n'.format(taskFinishedTime))
    return taskFinishedTime 
for mapMaxX,mapMaxY   in [(160,320),(320,320),(320,800),(640,800)]:
    # for numAnts in [800,400,200,100]:
        # for trial in range(1,10+1):
    run_one_test(trial) 