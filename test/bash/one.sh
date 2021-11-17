./two.sh docker \
      exec \
      -it \
      XXXXXX \
      mysql \
      --user=root \
      --password=password \
      --host=slayer \
      --port=3306 \
      -e \
      "CREATE USER 'me'@'localhost' IDENTIFIED BY 'mypassword'; GRANT ALL ON dcli.* TO 'me'@'slayer';" 