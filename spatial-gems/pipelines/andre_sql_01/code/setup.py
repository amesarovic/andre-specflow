from setuptools import setup, find_packages
setup(
    name = 'andre_sql_01',
    version = '1.0',
    packages = find_packages(include = ('andre_sql_01*', )) + ['prophecy_config_instances.andre_sql_01'],
    package_dir = {'prophecy_config_instances.andre_sql_01' : 'configs/resources/andre_sql_01'},
    package_data = {'prophecy_config_instances.andre_sql_01' : ['*.json', '*.py', '*.conf']},
    description = 'workflow',
    install_requires = [
'prophecy-libs==1.9.49'],
    entry_points = {
'console_scripts' : [
'main = andre_sql_01.pipeline:main'], },
    data_files = [(".prophecy", [".prophecy/workflow.latest.json"])],
    extras_require = {
'test' : ['pytest', 'pytest-html', 'pytest-cov'], }
)
