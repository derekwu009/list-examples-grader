CPATH=".;lib/hamcrest-core-1.3.jar;lib/junit-4.13.2.jar"

rm -rf student-submission
rm -rf grading-area

mkdir grading-area

git clone $1 student-submission 2> clone-output.txt
echo 'Finished cloning'

if ! [ -f student-submission/ListExamples.java ]
then 
    echo "File not found"
    exit
fi

cp TestListExamples.java student-submission/ListExamples.java grading-area
cp -r lib grading-area

cd grading-area

javac -cp $CPATH *.java 2> compile.txt
if [ $? -ne 0 ]
then
    echo "Compilation Error"
    echo $(cat compile.txt)
    exit 1
fi

java -cp $CPATH org.junit.runner.JUnitCore TestListExamples | tail -n 2 | head -n 1 > test-output.txt
testsRun=$(awk '{ print $3 }' test-output.txt | cut -d ',' -f 1)
if [ $(awk '{ print $1 }' test-output.txt) == "OK" ]
then
    tests=$(awk '{print $2}' test-output.txt | cut -d '(' -f 2)
    echo $tests/$tests "tests passed!"
    echo "Score = 100%"
else
    testsFailed=$(awk '{ print $5 }' test-output.txt)
    score=$(((testsRun/testsFailed)*100))
    echo $testsRun/$testsFailed "tests passed. Score = "$score"%."
fi