#!/usr/bin/env python
import sys
import subprocess
import html.parser


def main(cookie, tag, pages):
    results = []
    for i in range(1, pages + 1):
        page = '' 
        try:
            page = curl(cookie, tag, i)
        except UnicodeDecodeError:
            page = ''
            print("Unicode Error for tag: {} and page: {}".format(tag, i))
        results += parse_html(page)
    f = open('{}_stream.txt'.format(tag), 'w')
    for x in results:
        print(x.strip()+"\n", file=f)
    f.close()

def curl(cookie, tag, page):
    mother_of_curl = """curl 'http://keyhole.co/monitor/streaming/{}/{}/{}' -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: https://www.google.com/' -H 'Cookie: __utmx=77655950.dmOv4HxCS_aOQl1MacXeUQ$0:0; __utmxx=77655950.dmOv4HxCS_aOQl1MacXeUQ$0:1477148273:8035200; optimizelyEndUserId=oeu1477148274868r0.3195257045241304; _cio=6071ea43-2585-f2ee-23fd-361f4670498b; assetize[User][cookie]=Q2FrZQ%3D%3D.xeEMXJLT5MBllfwfIGUD1DH3XTV5L1Ks9NQt0%2F0AiC65EngcSugGtrCHbZYi%2BVNB5rkBRUaUplfNhfyOfFC14V6t7vT29tDKd%2BjP1Gk2Fv9fA8SfiG5n6avynDF2B4xP9BhGNEbRQ4cpQKD0YXirZ7knRE%2BUHd1kcOt%2BTlxxlvGTpPY1mXKtmj449cIc; _cioid=127736; __utmt=1; mp_mixpanel__c=17; __utma=77655950.2145892898.1477148276.1477148276.1477148276.1; __utmb=77655950.12.9.1477149232529; __utmc=77655950; __utmz=77655950.1477148276.1.1.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); ref_data=eyJyZWZfdXJsIjoiaHR0cHM6XC9cL3d3dy5nb29nbGUuY29tXC8iLCJyZWZfY29kZSI6Ijg5YmZmZCIsInJlZl9oYXNoIjoiS0N6bTEyIn0%3D; CAKEPHP=5fm53o0butokc1eaf1nq9ueie2; optimizelySegments=%7B%223551629830%22%3A%22false%22%2C%223584360908%22%3A%22gc%22%2C%223585270729%22%3A%22search%22%7D; optimizelyBuckets=%7B%7D; mp_913d764e386cd62956529ee36e468dfa_mixpanel=%7B%22distinct_id%22%3A%20%22127736%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22%24initial_referrer%22%3A%20%22https%3A%2F%2Fwww.google.com%2F%22%2C%22%24initial_referring_domain%22%3A%20%22www.google.com%22%2C%22plantype%22%3A%20%2220%22%2C%22trial%22%3A%20%221%22%2C%22ref_uid%22%3A%20%2236%22%2C%22email%22%3A%20%22coghlan.ty%40gmail.com%22%7D' -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' --compressed
  """.format(cookie, tag, page)
    input = subprocess.check_output(mother_of_curl, shell=True)
    if input == "\"AuthenticationFailed\"":
        sys.stderr.write("Authentication Failed!\n")
        sys.exit()
    else:
        return input.decode("utf-8")

def parse_html(html):
    parser = StreamParser(convert_charrefs=True)
    return parser.my_feed(html)


class StreamParser(html.parser.HTMLParser):
    tbody = False
    tr = False
    span = False
    result = []

    def handle_starttag(self, tag, attrs):
        if tag == 'tbody':
            self.tbody = True
        elif self.tbody and tag == 'tr':
            self.tr = True
        elif self.tbody and self.tr and tag == 'span' and not attrs:
            self.span = True

    def handle_endtag(self, tag):
        if tag == 'tbody':
            self.tbody = False
        elif self.tbody and tag == 'tr' and self.tr:
            self.tr = False
        elif self.tbody and self.tr and tag == 'span' and self.span:
            self.span = False

    def handle_data(self, data):
        if self.span:
            self.result.append(data)

    def my_feed(self, data):
        self.result = []
        self.feed(data)
        return self.result

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], int(sys.argv[3]))
