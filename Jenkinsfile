pipeline {
    agent any

    environment {
        PYTHONPATH = '.'
        PATH_VENV = '/opt/venv/bin'
        PATH_JMETER = '/opt/jmeter/bin'
    }

    stages {

        stage('Checkout code') {
            steps {
                git 'https://github.com/flaviooria/CI_bootcamp_24_unir.git'
                sh 'echo $WORKSPACE'
            }
        }
        
        stage('Run unit test') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh '$PATH_VENV/coverage run --branch --source=./app --omit=app/__init__.py,app/api.py -m pytest --junitxml=result-unit.xml test/unit'
                    sh '$PATH_VENV/coverage xml'
                }

                junit 'result-unit.xml'
            }
        }

        stage('Static') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh '$PATH_VENV/flake8 --format=pylint --exit-zero ./app > flake8.out'

                    recordIssues tools: [flake8(name: 'Flake8', pattern: 'flake8.out', reportEncoding: 'UTF-8')], qualityGates: [[threshold: 8.0, type: 'TOTAL', unstable: true], [threshold: 10.0, type: 'TOTAL', unstable: false]]
                }
            }
        }

        stage('Security') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh '$PATH_VENV/bandit --exit-zero -r . -f custom -o bandit.out --msg-template "{abspath}:{line}: [{test_id}] {severity} {msg}"'

                    recordIssues tools: [pyLint(name: 'Bandit', pattern: 'bandit.out')], qualityGates: [[integerThreshold: 2, threshold: 2.0, type: 'TOTAL'], [criticality: 'FAILURE', integerThreshold: 4, threshold: 4.0, type: 'TOTAL']]
                }
            }
        }

        stage('Coverage') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh '$PATH_VENV/coverage report'
                    
                    cobertura autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: 'coverage.xml', conditionalCoverageTargets: '100, 80, 90', failUnhealthy: false, failUnstable: false, lineCoverageTargets: '100, 85, 95', maxNumberOfBuilds: 0, onlyStable: false, zoomCoverageChart: false
                }

            }
        }

        stage('Performance') {
            steps {
                sh '$PATH_VENV/python app/api.py &' // Run the app in the background
                sh 'sleep 3' // Wait for the app to start

                sh '$PATH_JMETER/jmeter -n -t test/jmeter/flask.jmx -f -l flask.jtl'


                perfReport sourceDataFiles: 'flask.jtl'
            }
        }
    }

    post {
        always {
            cleanWs()
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