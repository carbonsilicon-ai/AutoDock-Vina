set -e

# cuda device id
device=4
# how many MC running concurrently
concurrent=1

curr=$(dirname $(realpath $0))
cuvina=$(dirname $curr)
echo "curr $curr cuvina $cuvina"

build=${cuvina}/build_cpu
mkdir -p $build
cd $build
#cmake -DDBG_BFGS_USE_CPU=ON -DCMAKE_BUILD_TYPE=Debug ${cuvina}
cmake -DDBG_BFGS_USE_CPU=ON -DCMAKE_BUILD_TYPE=Release ${cuvina}
make vina -j 16
mkdir -p ${cuvina}/test
cd ${cuvina}/test

# cuda-memcheck \
		#--cpu_only \
#nsys profile 
#cuda-gdb -ex=r --args \
#gdb -ex=r --args \


$build/vina --gpu ${device} --receptor $cuvina/example/python_scripting/1iep_receptor.pdbqt \
		--ligand $cuvina/example/python_scripting/1iep_ligand.pdbqt \
		--out ligs_out.pdbqt \
		--center_x 15.190 \
		--center_y 53.903 \
		--center_z 16.917 \
		--size_x 20 \
		--size_y 20 \
		--size_z 20 \
		--scoring vina \
		--num_modes 10 \
		--seed 123 \
		--verbosity 2 \
		--exhaustiveness $concurrent 2>&1 | tee ${curr}/cpu.log



