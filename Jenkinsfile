pipeline {
    agent { label 'dev' }

    environment {
        PYTHONPATH = '.'
        PATH_VENV = 'ci_venv/bin'
    }

    stages {
        stage('Checkout code') {
            steps {
                showAgentInfo()

                git url: 'https://github.com/flaviooria/CI_bootcamp_24_unir.git', branch: 'feature/fix_racecond'
            }
        }

        stage('List directories') {

            steps {
                showAgentInfo()

                sh 'ls -la'
            }
        }

        stage('install dependencies') {

            steps {
                showAgentInfo()

                sh 'python3 -m venv ci_venv'

                sh '$WORKSPACE/$PATH_VENV/pip install -r requirements.txt'

            }
        }

        stage('Build') {

            steps {
                showAgentInfo()

                echo 'Build ...'
            }
        }

        stage('Tests') {
            parallel {
                stage('Run unit test') {
                    
                    steps {
                        showAgentInfo()

                        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {

                            sh '$WORKSPACE/$PATH_VENV/pytest --junitxml=result-unit.xml test/unit'   
                        }

                        script {
                            if (fileExists("result-unit.xml")) {
                                stash name: 'unit-tests', includes: 'result-unit.xml'
                            }
                        }
                    }
                }

                stage('Run flask and wiremock') {
                    steps {
                        showAgentInfo()
                        sh 'nohup $WORKSPACE/$PATH_VENV/python app/api.py > api.log 2>&1 &'
                        sh 'echo $! > api_PID.txt'
                        sh 'nohup java -jar wiremock-standalone-3.10.0.jar --port 8083 > wiremock.log 2>&1 &'
                        sh 'echo $! > wiremock_PID.txt'
                    }
                }

                stage('Run test rest') {
                    steps {
                        sleep(time: 5, unit: 'SECONDS')
                        showAgentInfo()

                        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                            sh '$WORKSPACE/$PATH_VENV/pytest --junitxml=result-rest.xml test/rest'
                        }

                        script {
                            if (fileExists("result-rest.xml")) {
                                stash name: 'rest-tests', includes: 'result-rest.xml'
                            }
                        }
                    }
                }
            }
        }

        stage('Generate Reports') {
            agent { label 'reports' }

            steps {
                showAgentInfo()

                script {
                    try {
                        unstash 'unit-tests'
                        unstash 'rest-tests'
                        
                    } catch(err) {
                        echo "Caught: ${err}"
                    } finally {
                        echo 'Generating and publishing JUnit test reports...'
                        junit '**/result-*.xml'
                    }
                }
            }
        }

    }

    post {
      always {
        sh'''
        if [ -f api_PID.txt ]; then
          kill $(cat api_PID.txt) || true
          echo 'Flask server terminated'
        fi

        if [ -f wiremock_PID.txt ]; then
          kill $(cat wiremock_PID.txt) || true
          echo 'Wiremock server terminated'
        fi
        '''

        deleteDir()
      }
    }
}

def showAgentInfo() {
    script {
        sh '''
        echo "Current user: $(whoami)"
        echo "Current host: $(hostname)"
        echo "Workspace: $WORKSPACE"
        '''
    }
}