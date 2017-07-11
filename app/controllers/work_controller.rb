class WorkController < ApplicationController
  def index
    @data = ''
    #Document.delete_all
    update_home 'http://sasa.sjeduhs.kr/cop/bbs/selectBoardList.do?bbsId=BBSMSTR_000000002239&menuId=MNU_0000000000003262&pageIndex='
    update_home 'http://sasa.sjeduhs.kr/cop/bbs/selectBoardList.do?menuId=MNU_0000000000013879&bbsId=BBSMSTR_000000002240&pageIndex='
    update_home "http://sasa.sjeduhs.kr/cop/bbs/selectBoardList.do?bbsId=BBSMSTR_000000002258&menuId=MNU_0000000000013881&pageIndex="
    update_home "http://sasa.sjeduhs.kr/cop/bbs/selectBoardList.do?menuId=MNU_0000000000014497&bbsId=BBSMSTR_000000010958&pageIndex="
    Update.new(:updated_at => Time.now).save
  end
  def update_home(ln)
    page = 1
    while true
      doc = Nokogiri::HTML(open(ln + page.to_s))
      tr = doc.xpath("//tbody/tr")
      return if tr.to_s.include? "empty"
      tr.each do |ar|
        link = 'http://sasa.sjeduhs.kr' + ar.xpath("td[@class='tit']/a/@href").text.strip
        doc = Nokogiri::HTML(open(link))
        location =  doc.xpath("//div[@class='navi']/h2")[0].text.strip
        div = doc.xpath("//div[@class='board_view']")
        date = div.xpath("dl[@class='info_view2']/dd")[1].text.strip
        f = doc.xpath("//tr[@class='db']")
        f.each do |q|
          download = open('http://sasa.sjeduhs.kr' + q.xpath("td/a/@href").text.strip)
          name = download.meta['content-disposition'].match(/filename=(\"?)(.+)\1/)[2]
          size = download.size
          return if Document.exists?(:name => name, :location => location)
          @asd = Document.new(:name => name, :size => size, :location => location, :link => link, :uploaded_at => DateTime.parse(date))
          @data.concat(@asd.save.to_s).concat(' /')
          IO.copy_stream(download, '../files/' + name)
        end
      end
      page += 1
    end

    #render nothing: true
  end
end
