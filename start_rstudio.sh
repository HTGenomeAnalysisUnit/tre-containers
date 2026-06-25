#!/usr/bin/bash

# Set default values
IP_ADDRESS="0.0.0.0"
hostname=$(hostname)
Rstudio_data_dir="$HOME/Rstudio_data"

# Support function to print usage instructions
read -r -d '' help_msg << EOM
Usage: start_rstudio.sh -i rstudio.sif [OPTIONS]

Options:
  -i  rstudio_sif  		Path to the rstudio singularity image (mandatory)
  -m  folder_mounts		Additional directories to mount inside the singularity container (comma separated list)
  -d  data_dir			Directory to store Rstudio data (default: $HOME/Rstudio_data)

Example:
  start_rstudio.sh -i /my/path/rstudio-base.sif -m /project,/group
EOM

# Read command-line args
while getopts 'i:m:d:h' OPTION
do
  case "$OPTION" in
    i) sif_image="$OPTARG";;
    m) additional_mounts="$OPTARG";;
	d) Rstudio_data_dir="$OPTARG";;
	h) echo "$help_msg"; exit 0;;
	*) echo "$help_msg"; exit 1;;
  esac
done
shift "$(($OPTIND -1))"

# Exit with error if no image is provided
if [[ -z $sif_image ]]
then
	echo "Error: No R Studio image provided! Please provide a path to the R Studio singularity image using -i option."
	echo "Use -h option for help."
	exit 1
fi

# When no additional mounts are provided, give a warning
mount_option=""
if [[ -z $additional_mounts ]]
then
	echo "Warning: No additional mounts provided. Only data in your home folder will be accessible"
	echo "Use -m option to mount additional directories."
else
	for mount in $(echo $additional_mounts | tr "," "\n")
	do
		# Check if the directory exists or exit with error
		if [ ! -d $mount ]
		then
			echo "Error: -m required to mount the directory $mount"
			does "This folder does not exist!"
			exit 1
		fi
		mount_option="$mount_option -B $mount"
	done
fi

# Get a random free port
read LOWERPORT UPPERPORT < /proc/sys/net/ipv4/ip_local_port_range
while :
do
        PORT="`shuf -i $LOWERPORT-$UPPERPORT -n 1`"
        ss -lpn | grep -q ":$PORT " || break
done

# Check mandatory files exist
if [ ! -f $sif_image ]
then
	echo "$sif_image singularity image not found!"
	exit 1
fi

echo "=== CONFIGURATION FOR THIS SESSION ==="
echo "Running on Host: $hostname"
echo "R studio: $sif_image"
echo "Data directory: $Rstudio_data_dir"
echo "Server address: $IP_ADDRESS"
echo "Server port: $PORT"
echo "Additional paths to mount: $additional_mounts"
echo "======================================"
echo
echo "=== START RSTUDIO SERVER NOW ==="
echo "Once server started open localhost:$PORT on your browser"

# Make necessary folders
varlib_dir="$Rstudio_data_dir/var/lib"
varrun_dir="$Rstudio_data_dir/var/run"
tmp_dir="$Rstudio_data_dir/tmp"
cache_dir="$Rstudio_data_dir/cache"
share_dir="$Rstudio_data_dir/share"
config_dir="$Rstudio_data_dir/config"

mkdir -p $varlib_dir
mkdir -p $varrun_dir
mkdir -p $tmp_dir
mkdir -p $cache_dir
mkdir -p $share_dir
mkdir -p $config_dir

# Create rserver.conf to set the user
rserver_conf="$Rstudio_data_dir/rserver.conf"
echo "server-user=\"$USER\"" > $rserver_conf

# Start Rstudio server using the singularity image
singularity run --cleanenv --no-home \
	--env USER="$USER" \
	--bind $PWD \
	--bind ${config_dir}:${HOME}/.config/rstudio \
	--bind ${share_dir}:${HOME}/.local/share/rstudio \
	--bind ${cache_dir}:${HOME}/.cache/rstudio \
	--bind ${varlib_dir}:/var/lib/,${varrun_dir}:/var/run,${tmp_dir}:/tmp \
	--bind ${rserver_conf}:/etc/rstudio/rserver.conf \
	${mount_option} \
	${sif_image} \
	--auth-none=1 --server-user $USER --www-address=${IP_ADDRESS} --www-port=${PORT}
