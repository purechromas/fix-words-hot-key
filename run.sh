#!/bin/bash
# Запуск textfix в фоне (как docker compose up -d).
#   ./run.sh start   — запустить в фоне (окно терминала можно закрыть)
#   ./run.sh stop    — остановить
#   ./run.sh restart — перезапустить
#   ./run.sh status  — запущен ли
#   ./run.sh log     — смотреть лог в реальном времени
#
# Права берутся у Терминала: в «Универсальном доступе» и «Мониторинге ввода»
# должен быть включён Терминал (или iTerm — тот, из которого запускаете).

DIR="$(cd "$(dirname "$0")" && pwd)"
PIDFILE="$DIR/.textfix.pid"
LOG="$DIR/textfix.log"

running() {
  [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

case "$1" in
  start)
    if running; then
      echo "Уже запущен (pid $(cat "$PIDFILE"))."
      exit 0
    fi
    nohup "$DIR/venv/bin/python" -u "$DIR/main.py" >> "$LOG" 2>&1 < /dev/null &
    echo $! > "$PIDFILE"
    disown
    sleep 1
    if running; then
      echo "Запущен fix-test script в фоне (pid $(cat "$PIDFILE")). Лог: ./run.sh log"
    else
      echo "Не запустился, смотрите лог:"; tail -5 "$LOG"
    fi
    ;;
  stop)
    if running; then
      kill "$(cat "$PIDFILE")" && echo "Остановлен fix-test script."
    else
      echo "Не запущен."
    fi
    rm -f "$PIDFILE"
    ;;
  restart)
    "$0" stop; sleep 1; "$0" start
    ;;
  status)
    if running; then echo "Работает (pid $(cat "$PIDFILE"))."; else echo "Не запущен."; fi
    ;;
  log)
    tail -f "$LOG"
    ;;
  *)
    echo "Использование: $0 start | stop | restart | status | log"
    ;;
esac
