project = "Wordpress"

use_amazonlinux2 = true

instance_type = "t2.micro"

db_identifier = "wordpress-db"

db_instance_class = "db.t3.micro"

db_name = "wordpress"

db_user = "mark"

amzn2023_user_data = "scripts/amzn2023-user-data.sh"

amzn2_user_data = "scripts/amzn2-user-data.sh"

ubuntu_user_data = "scripts/ubuntu-user-data.sh"
