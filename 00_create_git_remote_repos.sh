# Filenaam: 00_create_git_remote_repos.sh
# Functie: create centrale remote git repository van de commandline
#          
#

# Tbv Ubuntu
curl -u 'cx1964@gmail.com' https://api.github.com/user/repos -d '{"name":"cx1964ReposPhysicalDBDesignAzureSQLMIPublic"}'

# tbv mingw64 onder windows
# letop vul voor <PASSWORD> een password waarde in
#curl -d '{"name":"cx1964ReposPhysicalDBDesignAzureSQLMIPublic"}' -u cx1964@gmail.com:<PASSWORD> https://api.github.com/user/repos

# maak de repository handmatig op de site private

# maak een lege repository
git init

# Voeg readme.md en *.sh scripts toe onder versie beheer plaats het in staging
# Iedere keer als men een file wilt committen, moet het eerst met add in staging gezet worden
# ook voor files die al een keer zijn gecommit.
git add *.sql
git add *.bat
git add *.cmd
git add *.sh
git add *.md
git add ./hulp/*

# set de identity
git config --global user.email "cx1964@mail.com"
git config --global user.name "cx1964"
git config --global core.editor "code --wait"

# commit de file
git commit *.* -m "Initiele files"

# Voeg een remote repository toe
git remote add origin https://github.com/cx1964/cx1964ReposPhysicalDBDesignAzureSQLMIPublic.git
                                               


# Schrijf de  wijzgingen van local repository naar master branch van de remote repository
# Gebruik username cx1964@gmail.com
git push -u origin master