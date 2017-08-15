class FilesController < ApplicationController
  def index
    @updated_at = Update.order('updated_at DESC').first.updated_at
    @data = Document.all

    d = params[:d]
    d = '@' if d.nil? or d.empty?
    startdate = d.split('@')[0]
    enddate = d.split('@')[1]
    @data = @data.where("uploaded_at >= ?", DateTime.parse(startdate).beginning_of_day) unless startdate.nil? or startdate.empty?
    @data = @data.where("uploaded_at <= ?", DateTime.parse(enddate).end_of_day) unless enddate.nil? or enddate.empty?

    q = params[:q]
    q = '' if q.nil?
    queries = q.split(',')
    queries.each {|query| @data = @data.where("name like ?", "%#{query}%")}

    b = params[:b]
    b = '1111' if b.nil? || b.empty?
    location = ['공지사항', '가정통신문', '자료실', '대회안내']
    b.split('').each_with_index {|l, i| @data = @data.where.not(:location => location[i]) if l.eql? '0'}
    @data = @data.order('uploaded_at DESC').page(params[:p]).per(20)
  end
  def download
    send_file '../files/' + params[:q]
  end

  def work
    @data = ''
    #Document.delete_all
    #return
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
          return if Document.exists?(:name => name, :location => location, :link => link)
          @asd = Document.new(:name => name, :size => size, :location => location, :link => link, :uploaded_at => ActiveSupport::TimeZone["Seoul"].parse(date))
          @data.concat(name).concat(' - ').concat(@asd.save.to_s).concat(' /')
          IO.copy_stream(download, '../files/' + name)
        end
      end
      page += 1
    end
  end
end
