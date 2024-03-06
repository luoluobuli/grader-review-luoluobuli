CPATH='.;../lib/hamcrest-core-1.3.jar;../lib/junit-4.13.2.jar'

rm -rf student-submission
rm -rf grading-area

mkdir grading-area

git clone $1 student-submission
echo 'Finished cloning'


# Draw a picture/take notes on the directory structure that's set up after
# getting to this point

# Then, add here code to compile and run, and do any post-processing of the
# tests

# Test if the file exists
if [ -f "student-submission/ListExamples.java" ]; then # Magic number: ListExamples.java
    echo "The correct file exists."
else
    echo "The correct file does not exist."
    echo "Your grade: 0"
    exit
fi

# Move the file into the new directory
cp student-submission/*.java Test*.java grading-area

# Test if the file compiles succesfully
cd grading-area
javac -cp $CPATH *.java
compile_exit_code=$?

if [ $compile_exit_code -ne 0 ]; then
    echo "File did not compile successfully."
    echo "Your grade: 0"
    exit
else
    echo "File compiled successfully."

    # Test if the file runs succesfully
    java -cp $CPATH org.junit.runner.JUnitCore TestListExamples > output.txt
    run_exit_code=$?
    cat output.txt

    if [ $run_exit_code -ne 0 ]; then
        echo "Program did not execute successfully."
        echo "Your grade: 0"
        exit
    else
        echo "Program executed successfully."
    fi
fi

total_tests=0
failures=0
errors=0
passed_tests=0

success_msg=$(grep -o "OK ([0-9]* test)" output.txt)

if [[ ! -z "$success_msg" ]]; then
    total_tests=$(echo $success_msg | grep -o "[0-9]*")
    passed_tests=$total_tests
else
    total_tests=$(grep -o "Tests run: [0-9]*" output.txt | awk '{print $3}')
    failures=$(grep -o "Failures: [0-9]*" output.txt | awk '{print $2}')
    errors=$(grep -o "Errors: [0-9]*" output.txt | awk '{print $2}')
    
    [[ -z "$total_tests" ]] && total_tests=0
    [[ -z "$failures" ]] && failures=0
    [[ -z "$errors" ]] && errors=0

    passed_tests=$((total_tests - failures - errors))
fi

echo "Your grade: $passed_tests/$total_tests"
