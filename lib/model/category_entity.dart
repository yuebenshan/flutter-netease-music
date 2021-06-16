import 'package:quiet/generated/json/base/json_convert_content.dart';
import 'package:quiet/generated/json/base/json_field.dart';

class CategoryEntity with JsonConvert<CategoryEntity> {
	@JSONField(name: "term_recommend_id")
	int termRecommendId;
	@JSONField(name: "term_id")
	int termId;
	String name;
	String taxonomy;
	String type;
	String description;
	String parent;
	@JSONField(name: "term_group")
	String termGroup;
}
