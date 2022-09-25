# vim: syntax=bash

@goal std.awk
@doc 'generates std.awk file used for documentation (Ctrl-Q)'
@depends_on std.awk_clean
@depends_on std.awk_variables1
@depends_on std.awk_variables2
@depends_on std.awk_close_BEGIN
@depends_on std.awk_numeric
@depends_on std.awk_string
@depends_on std.awk_io
@depends_on std.awk_time
@depends_on std.awk_bitwise
@depends_on std.awk_type
@depends_on std.awk_i18n
@depends_on std.awk_exit
@depends_on std.awk_printf

@goal temp_folder_created @private
@reached_if [[ -d temp ]]
  mkdir temp

@goal string_functions_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/String-Functions.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html -o temp/String-Functions.html

@goal numeric_functions_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/Numeric-Functions.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/Numeric-Functions.html -o temp/Numeric-Functions.html

@goal io_functions_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/IO-Functions.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/I_002fO-Functions.html -o temp/IO-Functions.html

@goal time_functions_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/Time-Functions.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/Time-Functions.html -o temp/Time-Functions.html

@goal bitwise_functions_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/Bitwise-Functions.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/Bitwise-Functions.html -o temp/Bitwise-Functions.html

@goal type_functions_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/Type-Functions.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/Type-Functions.html -o temp/Type-Functions.html

@goal i18n_functions_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/I18N-Functions.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/I18N-Functions.html -o temp/I18N-Functions.html

@goal sprintf1_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/Control-Letters.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/Control-Letters.html -o temp/Control-Letters.html

@goal sprintf2_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/Format-Modifiers.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/Format-Modifiers.html -o temp/Format-Modifiers.html

@goal variables1_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/User_002dmodified.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/User_002dmodified.html -o temp/User_002dmodified.html

@goal variables2_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/Auto_002dset.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/Auto_002dset.html -o temp/Auto_002dset.html

@goal exit_downloaded @private
@depends_on temp_folder_created
@reached_if [[ -f 'temp/Exit-Statement.html' ]]
  curl https://www.gnu.org/software/gawk/manual/html_node/Exit-Statement.html -o temp/Exit-Statement.html


@goal std.awk_clean @private
  echo 'BEGIN {' > src/main/resources/std.awk

@goal std.awk_close_BEGIN @private
  echo '}' >> src/main/resources/std.awk

@goal std.awk_numeric @private
@depends_on numeric_functions_downloaded
  awk -f gen_std.awk temp/Numeric-Functions.html >> src/main/resources/std.awk

@goal std.awk_string @private
@depends_on string_functions_downloaded
@depends_on sprintf1_downloaded
@depends_on sprintf2_downloaded
  awk -f gen_std.awk temp/String-Functions.html >> src/main/resources/std.awk

@goal std.awk_io @private
@depends_on io_functions_downloaded
  awk -f gen_std.awk temp/IO-Functions.html >> src/main/resources/std.awk

@goal std.awk_time @private
@depends_on time_functions_downloaded
  awk -f gen_std.awk temp/Time-Functions.html >> src/main/resources/std.awk

@goal std.awk_bitwise @private
@depends_on bitwise_functions_downloaded
  awk -f gen_std.awk temp/Bitwise-Functions.html >> src/main/resources/std.awk

@goal std.awk_type @private
@depends_on type_functions_downloaded
  awk -f gen_std.awk temp/Type-Functions.html >> src/main/resources/std.awk

@goal std.awk_i18n @private
@depends_on i18n_functions_downloaded
  awk -f gen_std.awk temp/I18N-Functions.html >> src/main/resources/std.awk

@goal std.awk_variables1 @private
@depends_on variables1_downloaded
  awk -v Vars=1 -f gen_std.awk temp/User_002dmodified.html >> src/main/resources/std.awk

@goal std.awk_variables2 @private
@depends_on variables2_downloaded
  awk -v Vars=1 -f gen_std.awk temp/Auto_002dset.html >> src/main/resources/std.awk

@goal std.awk_exit @private
@depends_on exit_downloaded
  awk -v Stmt=exit -f gen_std.awk temp/Exit-Statement.html >> src/main/resources/std.awk

@goal std.awk_printf @private
  awk -v Stmt=printf -f gen_std.awk >> src/main/resources/std.awk
