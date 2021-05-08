# PS5 Plz

This is an AWS Project to help you buy a PS5. It's written in Python & the infrastructure is managed by Terraform.

## Resources
* [Setting up a Selenium web scraper on AWS Lambda with Python](https://robertorocha.info/setting-up-a-selenium-web-scraper-on-aws-lambda-with-python/)
* [PyChromeless](https://github.com/jairovadillo/pychromeless)
* [Modern Web Automation With Python and Selenium](https://realpython.com/modern-web-automation-with-python-and-selenium/)
* [Creating Lambda container images](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html)
* [Testing Lambda container images locally](https://docs.aws.amazon.com/lambda/latest/dg/images-test.html)

## Issues
* `selenium.common.exceptions.WebDriverException: Message: unknown error: DevToolsActivePort file doesn't exist`
  * `chrome_options.add_argument("--disable-dev-shm-usage")`
  * `chrome_options.add_argument("--remote-debugging-port=0")`
  