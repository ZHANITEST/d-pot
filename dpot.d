import std.net.curl;
import std.stdio;
import std.regex;
import std.string;

const string PROGRAM_VERSION = "0.01";
enum BlogType{
	Egloos,
	NaverBlog,
	None
}

string getHtml(string url){
	return cast(string)get(url);
}

void makeDirectroy(string path){
	if(!std.file.exists(path)){ std.file.mkdir(path); }
}

string stripSpecialChars( string body_ ){
	string result = body_;
	string table[] = [ "\\", "/", ":", "*", "?", "<", ">", "|" ];
	foreach( e; table ){ result = result.replace( e, "_" ); }
	return result;
}

// 이글루스 모듈
class EgloosBlog{
	string base_url;
	string[string][] categorys;

	private string[][] parsingCategorys(){
		string[][] result = null;
		string html = getHtml(base_url);
		auto matces = matchAll(html, regex("a href=\"(/category/[\\S]*)\">(.+)</a>"));

		// 파싱한 RegexMatch를 배열로 변환
		if(!matces.empty()){
			foreach( e;matces ){ result ~= [e[1], e[2]]; }
		}
		return result;
	}

	protected string[string][] getCategorys(){
		string[string][] result = null;
		foreach(element;parsingCategorys()){
			result ~= [element[1]:element[0]];
		}
		return result;
	}

	protected string[] getKeysOfCategory(){
		string[] result;
		foreach(element;parsingCategorys()){
			result ~= element[1];
		}
		return result;
	}

	protected string[] getValuesOfCategory(){
		string[] result;
		foreach(element;parsingCategorys()){
			result ~= element[0];
		}
		return result;
	}

	this(string base_url){
		this.base_url = base_url;
	}
}
// 블로그 타입 확인
BlogType check_blog_type(string url){
	auto m_egloos = match( url, regex("[\\W-]*\\.egloos\\.com") );
	auto m_naverblog = match( url, regex("blog.naver.com/[\\W-]*") );

	if( !m_egloos.empty() ){
		return BlogType.Egloos;
	}
	else if( !m_naverblog.empty() ){
		return BlogType.NaverBlog;
	}
	return BlogType.None;
}

class Naver{

}

void main(){
	string blog_url;

	writeln("********************************************************************************");
	writeln("* D-pot: Egloos backup tool.");
	writeln("* v"~PROGRAM_VERSION);
	writeln("********************************************************************************");
	writeln("@ Input your id.");

	bool yes = false;
	while( !yes ){
		write("Input>>> ");
		string cmd_id = chomp(readln());

		write("@ Your blog url is [ "~cmd_id~".egloos.com ]? / ( [y]es , [n]o )\nInput>>> ");
		string cmd_answer = chomp(readln());

		switch( cmd_answer ){
			case "y":
				yes = true;
				blog_url = cmd_id~".egloos.com";
				writeln("@ Yay! saved.");
			break;

			case "n":
				yes = false;
				writeln("# Ok, input again please!");
			break;

			default:
				writeln("# Unknow keyword. input again please!");
			break;
		}
	}

	writeln("********************************************************************************");
	writeln("* Step.01 - checking u r blog.");
	writeln("********************************************************************************");
	string html = getHtml(blog_url);
	if( html.indexOf("a href=\"/category/") != -1 )
	{
		writeln("@ Found it!");
		auto blog = new EgloosBlog(blog_url);

		// 블로그 폴더부터 만든다.
		string[] category_names = blog.getKeysOfCategory();
		makeDirectroy(blog_url);
		foreach( category_name; category_names ){
			makeDirectroy(blog_url~"/"~stripSpecialChars(category_name));
			writeln("@ Make '"~category_name~"' folder.");
		}
	}
	else{
		writeln("# Not Found!("~blog_url~")");
	}
}