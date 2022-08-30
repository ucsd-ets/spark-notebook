function ping_check() {
  netcat -zvw10 spark-main 7077
  return $?
}
until ping_check; do
    if [ $? -eq 0 ]; then
        break
    fi
    # potentially, other code follows...
    echo "Checking again in 5 seconds"
    sleep 5
done