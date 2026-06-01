#!/bin/bash

# Проверка входного аргумента
if [ $# -ne 1 ]; then
    echo "Usage: $0 <audit-log-file>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="audit-extract.json"

# Проверка наличия jq
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq first."
    exit 1
fi

# Проверка существования входного файла
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found."
    exit 1
fi

# Извлечение подозрительных событий
jq -n '
    [inputs | select(
        # 1. Доступ к secrets (чтение)
        (.objectRef.resource == "secrets" and .verb == "get") or

        # 2. kubectl exec в чужие поды (создание подресурса exec)
        (.verb == "create" and .objectRef.subresource == "exec") or

        # 3. Привилегированные поды (проверка всех контейнеров)
        (.objectRef.resource == "pods" and
         any(.requestObject?.spec.containers[]?.securityContext?.privileged == true; .)) or

        # 4. Изменение или удаление audit policy (поиск подстроки в любом поле)
        (tostring | test("audit-policy"; "i"))
    )]
' "$INPUT_FILE" > "$OUTPUT_FILE"

# Проверка результата выполнения jq
if [ $? -ne 0 ]; then
    echo "Error during processing. Check log file format."
    exit 1
fi

# Общее количество событий
TOTAL=$(jq length "$OUTPUT_FILE" 2>/dev/null || echo 0)

# Подсчёт по типам
SECRETS_COUNT=$(jq '[.[] | select(.objectRef.resource=="secrets" and .verb=="get")] | length' "$OUTPUT_FILE" 2>/dev/null || echo 0)
EXEC_COUNT=$(jq '[.[] | select(.verb=="create" and .objectRef.subresource=="exec")] | length' "$OUTPUT_FILE" 2>/dev/null || echo 0)
PRIV_COUNT=$(jq '[.[] | select(.objectRef.resource=="pods" and any(.requestObject?.spec.containers[]?.securityContext?.privileged==true; .))] | length' "$OUTPUT_FILE" 2>/dev/null || echo 0)
AUDIT_COUNT=$(jq '[.[] | select(tostring | test("audit-policy"; "i"))] | length' "$OUTPUT_FILE" 2>/dev/null || echo 0)

# Вывод результатов
echo "Extracted suspicious events to $OUTPUT_FILE"
echo "============================================"
echo "Total unique suspicious events: $TOTAL"
echo "Details by type:"
echo "  - Secrets access (get):          $SECRETS_COUNT"
echo "  - kubectl exec into pods:        $EXEC_COUNT"
echo "  - Privileged pods:               $PRIV_COUNT"
echo "  - Audit policy changes:          $AUDIT_COUNT"
echo "============================================"