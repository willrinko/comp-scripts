#!/bin/bash
# Will Rinko - Propaganda Manage Accounts - 11.19.24
OUT_OF_SCOPE_USERS=("whiteteam" "grayteam" "blackteam" "dd-agent" "root")
ADMIN_USERS=("president" "vicepresident" "defenseminister" "secretary")
LOCAL_USERS=("general" "admiral" "judge" "bodyguard" "cabinetofficial" "treasurer")
ADMIN_GROUP="sudo"
LOCAL_GROUP="users"
echo "Managing user accounts..."
is_in_list() {
    local user=$1
    shift
    local list=("$@")
    for item in "${list[@]}"; do
        if [[ "$user" == "$item" ]]; then
            return 0
        fi
    done
    return 1
}
for user in $(cut -d: -f1 /etc/passwd); do
    uid=$(id -u "$user")
    # Skip system accounts and out-of-scope users
    if [ "$uid" -lt 1000 ] && [ "$uid" -ne 0 ]; then
        echo "Skipping system account: $user"
        continue
    fi
    if is_in_list "$user" "${OUT_OF_SCOPE_USERS[@]}"; then
        echo "Skipping out-of-scope user: $user"
        continue
    fi
    if is_in_list "$user" "${ADMIN_USERS[@]}"; then
        echo "Ensuring $user is an administrator..."
        usermod -aG "$ADMIN_GROUP" "$user" || echo "Failed to modify $user."
    elif is_in_list "$user" "${LOCAL_USERS[@]}"; then
        echo "Ensuring $user is a local user..."
        usermod -G "$LOCAL_GROUP" "$user" || echo "Failed to modify $user."
    else
        # User is not authorized, remove them
        echo "User $user is unauthorized. Locking the account for investigation."
        pkill -u "$user" 2>/dev/null || echo "No processes to kill for $user."
        usermod --lock "$user" || echo "Failed to lock user $user."
        usermod --shell /sbin/nologin "$user" || echo "Failed to disable shell for $user."
        echo "User $user locked and shell disabled (evidence preserved)."
    fi
done
create_user_if_missing() {
    local username=$1
    local role_group=$2
    if ! id "$username" &>/dev/null; then
        echo "Creating missing user: $username..."
        useradd -m "$username"
        usermod -aG "$role_group" "$username"
        echo "Enter a new password for $username:"
        read -s new_password
        echo "Confirm the new password for $username:"
        read -s confirm_password
        if [ "$new_password" != "$confirm_password" ]; then
            echo "Passwords do not match. Skipping password setup for $username."
            return
        fi
        echo "$username:$new_password" | chpasswd
        echo "User $username created and password set."
    fi
}
for user in "${ADMIN_USERS[@]}"; do
    create_user_if_missing "$user" "$ADMIN_GROUP"
done
for user in "${LOCAL_USERS[@]}"; do
    create_user_if_missing "$user" "$LOCAL_GROUP"
done
echo "User account management complete."