pipeline {
    agent any

    triggers {
        githubPush()
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform Action'
        )
        choice(
            name: 'ENV',
            choices: ['dev', 'qa', 'prod'],
            description: 'Environment'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: true,
            description: 'Auto approve Terraform'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_DIR = "${WORKSPACE}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out code..."
                git branch: 'main', url: 'https://github.com/Nagendrappa/multienv_pipeline.git'
            }
        }

        stage('Terraform Init') {
            steps {
                echo 'Initializing Terraform...'
                dir("${TF_DIR}") {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']
                    ]) {
                        sh '''
                        terraform --version
                        terraform init -reconfigure
                        '''
                    }
                }
            }
        }

        stage('Workspace Setup') {
            steps {
                echo "Setting up workspace for ${params.ENV}"
                dir("${TF_DIR}") {
                    sh """
                    terraform workspace select ${params.ENV} || terraform workspace new ${params.ENV}
                    terraform workspace list
                    """
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'plan' }
            }
            steps {
                echo "Running Terraform Plan for ${params.ENV}"
                dir("${TF_DIR}") {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']
                    ]) {
                        sh """
                        terraform plan -var="env=${params.ENV}" -no-color
                        """
                    }
                }
            }
        }

        stage('Approval for PROD') {
            when {
                expression { params.ENV == 'prod' && params.ACTION == 'apply' }
            }
            steps {
                input message: "Approve Terraform APPLY for PROD?"
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo "Applying Terraform for ${params.ENV}"
                dir("${TF_DIR}") {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']
                    ]) {
                        sh """
                        terraform apply -var="env=${params.ENV}" ${params.AUTO_APPROVE ? '-auto-approve' : ''} -no-color
                        """
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                echo "Destroying Terraform for ${params.ENV}"
                dir("${TF_DIR}") {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']
                    ]) {
                        sh """
                        terraform destroy -var="env=${params.ENV}" ${params.AUTO_APPROVE ? '-auto-approve' : ''} -no-color
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully for ${params.ENV} with action ${params.ACTION}"
        }
        failure {
            echo "Pipeline failed! Check logs."
        }
    }
}
