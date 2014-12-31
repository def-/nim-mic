# For the Xeon Phi compile with:
# nim -d:release --gcc.exe:icc --gcc.linkerexe:icc --passC:-mmic --passL:-mmic c helloflops

import times

{.passl: "-fopenmp".}
{.passc: "-fopenmp".}

proc omp_get_num_threads(): int {.header: "<omp.h>".}
proc omp_set_num_threads(int) {.header: "<omp.h>".}

const
  flopsArraySize = 1024*1024
  maxFlopsIter = 100_000_000
  loopCount = 128
  flopsPerCalc = 2

var fa {.codegenDecl: "$# $# __attribute__((align(64)))".}: array[flopsArraySize, float32]
var fb {.codegenDecl: "$# $# __attribute__((align(64)))".}: array[flopsArraySize, float32]

let a: float32 = 1.1
var numThreads: int

echo "Initializing"
#ompSetNumThreads(4)
for i in 0 || < flopsArraySize:
  if i == 0: numThreads = ompGetNumThreads()
  fa[i] = float32(i) + 0.1
  fb[i] = float32(i) + 0.2

echo "Starting Compute on ", numThreads, " threads"
let tstart = epochTime()
for i in 0 || < numThreads:
  let offset = i * loopCount
  for j in 0 .. < maxFlopsIter:
    for k in 0 .. < loopCount:
      fa[k+offset] = a * fa[k+offset] + fb[k+offset]
let tstop = epochTime()
let ttime = tstop - tstart
let gflops = 1.0e-9 * float32(numThreads) * loopCount * maxFlopsIter * flopsPerCalc

if ttime > 0:
  echo "GFlops = ", gflops, ", Secs = ", ttime
  echo "GFlops per sec = ", gflops/ttime
