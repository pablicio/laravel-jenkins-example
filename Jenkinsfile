node {
    stage('Checkout Repo') {
        git branch: 'main', url: 'https://github.com/pablicio/laravel-jenkins-example.git'
    }
    stage('list php version') {
        sh 'php -v'
    }
}
