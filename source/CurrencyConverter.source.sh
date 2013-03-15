# 使用方式:
# ------
# convert 10 <3 位字母代碼> [to <3 位字母代碼>]

# 範例（4 個範例皆顯示同樣結果）：
# -----------------------------------------
# convert 10 USD = TWD
# convert 10 USD TWD
# convert 10 USD (使用 預設='TWD')
# convert 10 $ = TWD

# 設定 (你可以在此編輯):
# ----------------------------
# Default Target Currency - if no 3rd argument is provided,
# the amount is converted to the default target currency.

DEFAULTTARGET='TWD'
DEFAULTAMOUNT='1'

# SCRIPT（除非知道自己在做什麼，否則不要更動）：
# ------------------------------------------------------------
# Before using this in alfred replace $1 in the following line with {query}.
# Replace currency symbols with their 3 letter codes.
QUERY=`echo {query} " " | sed "s/ $ / USD /g;s/ € / EUR /g;s/ £ / GBP /g;s/ ¥ / JPY /g"`

# 將 Alfred 查詢字串切割成四個部分，'金額' '轉換幣值' '=' '目標幣值'：
AMOUNT=`echo $QUERY | awk '{ print toupper($1); }' | sed 's/,/./g'`
INPUT=`echo $QUERY | awk '{ print toupper($2); }' `
TO=`echo $QUERY | awk '{ print toupper($3); }'`
TARGET=`echo $QUERY | awk '{ print toupper($4); }'`
NUMBERAMOUNT=`echo $AMOUNT | awk '/[0-9]/ { print substr($1,1); }' `

# Check if we have TO/target, otherwise use default target.
if [ "$TARGET" = "" ]; then # Check if a TO is provided, otherwise use TO as Target.
TARGET=$DEFAULTTARGET
if [ "$TO" = "" ]; then # 未偵測到 '=' 後的值（100 USD）
if [ "$INPUT" != "" ]; then
if [ "$NUMBERAMOUNT" = "" ]; then # '金額' 為貨幣代碼（USD EUR）
TARGET=$INPUT
INPUT=$AMOUNT
AMOUNT=$DEFAULTAMOUNT
fi
else # '金額' 貨幣代碼對預設貨幣（USD）
INPUT=$AMOUNT
AMOUNT=$DEFAULTAMOUNT
fi
else # 100 USD =
if [ "$TO" != "=" ]; then # 100 USD TWD
TARGET=$TO
fi
fi
fi




# Check length of Input and Target strings - we're looking for 3 letter codes.
if [ "${#INPUT}" -le 3 ] && [ "${#TARGET}" -le 3 ]; then
# Get exchange rate
if [ "$TARGET" != "$INPUT" ]; then
RESULT=`curl -s "http://www.google.com/finance/converter?a=$AMOUNT&from=$INPUT&to=$TARGET" | awk '/<span/{print}' | sed -e 's/<[^>][^>]*>//g' -e '/^ *$/d'`
if [ "$RESULT" != "" ]; then
echo $RESULT
echo 'Google Finance 資訊提供'
else
echo '查詢未知的貨幣代碼。'
fi
else
echo '試試查詢不同的貨幣或更改預設貨幣？'
fi
else
echo 'Please use 3-letter currency codes (e.g. USD) or use one of the following symbols: $, €, £, ¥.'
fi