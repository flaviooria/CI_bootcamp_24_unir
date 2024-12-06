pipeline {
    agent any
    
    environment {
        PYTHONPATH='.'
        PATH_VENV='ci_venv/bin'
    }
    
    stages {
        
        stage('checkout code') {
            steps {
                git 'https://github.com/flaviooria/CI_bootcamp_24_unir.git'
            }
        }

        stage('list directories') {
            steps {
                sh 'ls -la'
            }
        }
        
        stage('Create virtualenv') {
            steps {
                sh 'python -m venv ci_venv'
            
                sh '. $PATH_VENV/activate'
                
                sh './$PATH_VENV/pip install -r requirements.txt'
            }
        }

        stage('show workspace') {
            steps {
                sh 'echo $WORKSPACE'
            }
        }

        stage('Build') {
            steps {
                echo 'Build ...'
            }
         
        }
    }
}