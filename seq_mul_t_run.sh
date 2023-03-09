#!/bin/bash
counter=0
debug=0
device="sdc"
# md1
bs="4K"
runtime=100
numjobs=1

while [[ "$#" -gt 0 ]]; do
	case $1 in
		-t|--test) debug=1 ;;
		-d|--device) device="$2"; shift ;;
		-b|--block) bs="$2"; shift ;;
		*) ;;
	esac
	shift
done

dirname="$device-$bs-$runtime"
mkdir $dirname

init () {
	rw="read"
	iodepth=16
}

run_fio() {
	let counter+=1
	long_iodepth=$(printf "%03d" $iodepth)
	filename="$rw-$device-$bs-$long_iodepth-$numjobs-$runtime.txt"
	if [[ $debug -eq 0 ]]; then
		rw=$rw device=$device runtime=$runtime bs=$bs iodepth=$iodepth numjobs=$numjobs fio config.fio > "$dirname/$filename"
	else
		touch "$dirname/$filename"
	fi
	echo -e "$counter\t$filename"
}

rw_test () {
	init
	rw_pool=('randread' 'randwrite')
	for i in {1..1}; do
		for rw in "${rw_pool[@]}"; do
			for numjobs in {1,2,4,8,16,32};do
				run_fio
			done
		done
		let iodepth\*=2
	done
}

rw_test

echo "bye"
