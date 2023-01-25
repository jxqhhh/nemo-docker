#! /bin/bash

#import subprocess
#process=subprocess.Popen("./nemo-data.sh -c 3 -i 240 -o 1080 -m create",stdout=subprocess.PIPE, shell=True, executable='/bin/bash')
#proc_stdout = process.communicate()[0].strip()
#print(proc_stdout)

#import subprocess
#process=subprocess.Popen("./nemo-data.sh -c 3 -i 240 -o 1080 -m delete",stdout=subprocess.PIPE, shell=True, executable='/bin/bash')
#proc_stdout = process.communicate()[0].strip()
#print(proc_stdout)

function _set_bitrate(){
    if [ "$1" == 240 ];then
        bitrate=512
    elif [ "$1" == 360 ];then
        bitrate=1024
    elif [ "$1" == 480 ];then
        bitrate=1600
    fi
}

function _set_input_video_name(){
    input_video_name="${input_resolution}p_${bitrate}kbps_s0_d300.webm"
}

function _set_output_video_name(){
    output_video_name="2160p_12000kbps_s0_d300.webm"
}


while getopts ":c:i:o:m:" opt; do
	case $opt in
		c) content="$OPTARG";;
		i) input_resolution="$OPTARG";;
		o) output_resolution="$OPTARG";;
		m) echo "$OPTARG";mode="$OPTARG";;
		\?) exit 1;;
	esac
done

if [ "${mode}" == "create" ];then
	echo "Step 1: generating raw images"
	sudo docker start nemo
	sudo docker exec nemo bash -c "/workspace/nemo/nemo/tool/script/save_youtube_dataset.sh -c ${content} -i ${input_resolution} -o ${output_resolution}"

	echo "Step 2: move data to the dataset folder"
	src=/data/jinxinqi/SuperResolution/nemo/nemo-docker-volume/nemo-data/${content}/image
	postfix=exported
	dst=/data/jinxinqi/Dataset/SuperResolution/NEMO-Dataset/${content}/image
	_set_bitrate ${input_resolution}
	_set_input_video_name
	sudo mkdir -p ${dst}/${input_video_name}
	sudo mv ${src}/${input_video_name}/${postfix}/*.raw ${dst}/${input_video_name}
	sudo chown -R jinxinqi ${dst}/${input_video_name}
	_set_output_video_name
	sudo mkdir -p ${dst}/${output_video_name}
	sudo mv ${src}/${output_video_name}/${postfix}/*.raw ${dst}/${output_video_name}
	sudo chown -R jinxinqi ${dst}/${output_video_name}
elif [ "${mode}" == "delete" ];then
	echo "Step 1: delete data"
	dst=/data/jinxinqi/Dataset/SuperResolution/NEMO-Dataset/${content}/image
	_set_bitrate ${input_resolution}
	_set_input_video_name
	echo "rm -rf ${dst}/${input_video_name}"
	sudo rm -rf ${dst}/${input_video_name}
	_set_output_video_name
	echo "rm -rf ${dst}/${output_video_name}"
	sudo rm -rf ${dst}/${output_video_name}
fi
