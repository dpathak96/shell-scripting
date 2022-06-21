# Printing in shell is done by echo command
# syntax : echo INPUT MESSAGE

echo world
echo Hello World

# We can also print text in colours
# Syntax : echo -e "\e[COmMESSAGE\e[0m"

## -e - To enable \e
## \e[ - To enable colours
## COL - colour code
## m - End of Syntax
## 0 - To disable colour

echo hello World

## Colour codes
# Red - 31
# Green 32
# Yellow - 33

echo -e "\e[31mHello In Red colour\e[0m"
echo -e "\e[32mHello In Green colour\e[0m"


