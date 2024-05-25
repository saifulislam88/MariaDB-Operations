#!/bin/bash

# Variables
DB_HOST="localhost"
DB_ROOT_USER="root"
DB_ROOT_PASS="t0mc@t"

# Function to print existing databases
print_databases() {
    echo "Existing databases:"
    mysql -h $DB_HOST -u $DB_ROOT_USER -p$DB_ROOT_PASS -e "SHOW DATABASES;"
}

# Function to print existing tables in the selected database
print_tables() {
    echo "Existing tables in database '$DB_NAME':"
    mysql -h $DB_HOST -u $DB_ROOT_USER -p$DB_ROOT_PASS -e "SHOW TABLES IN $DB_NAME;"
}

# Function to print users and their permissions for the selected database
print_users_and_permissions() {
    echo "Users and their permissions for database '$DB_NAME':"
    mysql -h $DB_HOST -u $DB_ROOT_USER -p$DB_ROOT_PASS -e "SELECT user, host, db, Select_priv, Insert_priv, Update_priv, Delete_priv FROM mysql.db WHERE db = '$DB_NAME';"
}

# Function to print all MySQL users with their associated databases and hosts
print_all_users_with_db_host() {
    echo "Please select an option:"
    echo "a. Show all users and hosts with Global PRIVILEGES"
    echo "b. Show users who are for specific databases"
    read -p "Enter your choice: " user_option
    case $user_option in
        a)
            echo "All MySQL users with their associated databases and hosts:"
            mysql -h $DB_HOST -u $DB_ROOT_USER -p$DB_ROOT_PASS -e "SELECT user, host, Show_db_priv FROM mysql.user;"
            ;;
        b)
            echo "Users who are associated with specific databases:"
            mysql -h $DB_HOST -u $DB_ROOT_USER -p$DB_ROOT_PASS -e "SELECT user, host, db FROM mysql.db;"
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
}

# Function to create a new database
create_database() {
    read -p "Enter the database name: " DB_NAME
    echo "Creating database..."
    mysql -h $DB_HOST -u $DB_ROOT_USER -p$DB_ROOT_PASS <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
EOF
}

# Function to create a new database user with access to all databases
create_database_user_all_dbs() {
    read -p "Enter the database user: " DB_USER
    read -s -p "Enter the database user password: " DB_USER_PASS
    echo ""
    read -s -p "Retype the database user password: " DB_USER_PASS_CONFIRM
    echo ""

    if [ "$DB_USER_PASS" != "$DB_USER_PASS_CONFIRM" ]; then
        echo -e "\e[91mPasswords do not match. Please try again.\e[0m"
        return
    fi

    read -p "Do you want to grant this user access from all hosts? (y/n): " all_hosts
    if [ "$all_hosts" == "y" ]; then
        HOST="%"
    else
        read -p "Enter the host: " HOST
    fi

    echo "Creating database user with access to all databases..."
    mysql -h $DB_HOST -u $DB_ROOT_USER -p$DB_ROOT_PASS <<EOF
CREATE USER IF NOT EXISTS '$DB_USER'@'$HOST' IDENTIFIED BY '$DB_USER_PASS';
GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'$HOST' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
}

# Function to create a new database user with access to a specific database
create_database_user_specific_db() {
    read -p "Enter the database user: " DB_USER
    read -s -p "Enter the database user password: " DB_USER_PASS
    echo ""
    read -s -p "Retype the database user password: " DB_USER_PASS_CONFIRM
    echo ""

    if [ "$DB_USER_PASS" != "$DB_USER_PASS_CONFIRM" ]; then
        echo -e "\e[91mPasswords do not match. Please try again.\e[0m"
        return
    fi

    read -p "Enter the database name: " DB_NAME
    read -p "Do you want to grant this user access from all hosts? (y/n): " all_hosts
    if [ "$all_hosts" == "y" ]; then
        HOST="%"
    else
        read -p "Enter the host: " HOST
    fi

    echo "Creating database user with access to database '$DB_NAME'..."
    mysql -h $DB_HOST -u $DB_ROOT_USER -p$DB_ROOT_PASS <<EOF
CREATE USER IF NOT EXISTS '$DB_USER'@'$HOST' IDENTIFIED BY '$DB_USER_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$HOST' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
}

# Function to delete a database user
delete_database_user() {
    print_all_users_with_db_host
    read -p "Enter the username to delete: " DB_USER
    read -p "Enter the host for the user: " HOST
    echo "Deleting user '$DB_USER' from host '$HOST'..."
    mysql -h $DB_HOST -u $DB_ROOT_USER -p$DB_ROOT_PASS <<EOF
DROP USER '$DB_USER'@'$HOST';
FLUSH PRIVILEGES;
EOF
}

# Function to delete a database
delete_database() {
    print_databases
    read -p "Enter the database name to delete: " DB_NAME
    echo "Deleting database '$DB_NAME'..."
    mysql -h $DB_HOST -u $DB_ROOT_USER -p$DB_ROOT_PASS <<EOF
DROP DATABASE IF EXISTS $DB_NAME;
EOF
}

# Main menu options
while true; do
    echo ""
    echo "Please select an option:"
    echo "1. Show databases"
    echo "2. Show all users with their associated databases and hosts"
    echo "3. Existing Database management [UserAdding,Delete,TableAdding,DataInsert]"
    echo "4. Create database"
    echo "5. Create database user[All OR Specific Database]"
    echo "6. Delete a database"
    echo "7. Delete a database user"
    echo "8. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            print_databases
            ;;
        2)
            print_all_users_with_db_host
            ;;
        3)
            echo " Existing Database management options:"
            echo "a. Show databases & then input database name for managing"
            read -p "Enter your choice: " db_manage_choice

            case $db_manage_choice in
                a)
                    print_databases
                    read -p "Enter the database name to select for managing: " DB_NAME
                    while true; do
                        echo ""
                        echo -e "\e[91mSelected database: $DB_NAME\e[0m"
                        echo ""
                        echo "Please select an option:"
                        echo ""
                        echo "1. Show users and permissions from selected database"
                        echo ""
                        echo "2. Create database user on selected database"
                        echo ""
                        echo "3. Delete a database user from selected database"
                        echo ""
                        echo "4. Show tables from selected database"
                        echo ""
                        echo "5. Create table on selected database"
                        echo ""
                        echo "6. Delete a table from selected database"
                        echo ""
                        echo "7. Insert data into table on selected database"
                        echo ""
                        echo "8. Read data from table on selected database"
                        echo ""
                        echo "9. Show columns and rows from table on selected database"
                        echo ""
                        echo "10. Back to main menu"
                        echo ""
                        read -p "Enter your choice: " db_choice

                        case $db_choice in
                            1)
                                print_users_and_permissions
                                ;;
                            2)
                                create_database_user_specific_db
                                ;;
                            3)
                                delete_database_user
                                ;;
                            4)
                                print_tables
                                ;;
                            5)
                                create_table
                                ;;
                            6)
                                delete_table
                                ;;
                            7)
                                insert_data
                                ;;
                            8)
                                read_data
                                ;;
                            9)
                                print_columns_and_rows
                                ;;
                            10)
                                break
                                ;;
                            *)
                                echo "Invalid option. Please try again."
                                ;;
                        esac
                    done
                    ;;
                *)
                    echo "Invalid option. Please try again."
                    ;;
            esac
            ;;
        4)
            create_database
            ;;
        5)
            echo "Please select an option:"
            echo "a. Create database user for all databases"
            echo "b. Create database user for specific database"
            read -p "Enter your choice: " user_choice
            case $user_choice in
                a)
                    create_database_user_all_dbs
                    ;;
                b)
                    create_database_user_specific_db
                    ;;
                *)
                    echo "Invalid option. Please try again."
                    ;;
            esac
            ;;
        6)
            delete_database
            ;;
        7)
            delete_database_user
            ;;
        8)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
