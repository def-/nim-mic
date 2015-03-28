# For the Xeon Phi compile with:
# nim -d:release --gcc.exe:icc --gcc.linkerexe:icc --passC:-mmic --passL:-mmic c hellomem

import times

{.passl: "-fopenmp".}
{.passc: "-fopenmp".}

proc omp_get_num_threads(): int {.header: "<omp.h>".}
proc omp_set_num_threads(x: int) {.header: "<omp.h>".}

const
  bwArraySize = 1024*1024*64
  bwIters = 1000
  opsPerIter = 2

var fa {.codegenDecl: "$# $# __attribute__((align(64)))".}: array[bwArraySize, float64]
var fb {.codegenDecl: "$# $# __attribute__((align(64)))".}: array[bwArraySize, float64]
var fc {.codegenDecl: "$# $# __attribute__((align(64)))".}: array[bwArraySize, float64]

let a: float64 = 1.1
var numThreads: int

echo "Initializing"
#ompSetNumThreads(4)
for i in 0 || < bwArraySize:
  numThreads = ompGetNumThreads()
  fa[i] = float64(i) + 0.1
  fb[i] = float64(i) + 0.2
  fc[i] = float64(i) + 0.2

echo "Starting BW Test on on ", numThreads, " threads"
let tstart = epochTime()
for i in 0 .. < bwIters:
  for k in 0 || < bwArraySize:
      fa[k] = fb[k];
let tstop = epochTime()
let ttime = tstop - tstart
let gbytes = 1.0e-9 * opsPerIter * bwIters * bwArraySize * float(sizeof(float64))

if ttime > 0:
  echo "GBytes = ", gbytes, ", Secs = ", ttime
  echo "GBytes per sec = ", gbytes/ttime
