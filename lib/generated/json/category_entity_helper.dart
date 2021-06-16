import 'package:quiet/model/category_entity.dart';

categoryEntityFromJson(CategoryEntity data, Map<String, dynamic> json) {
	if (json['term_recommend_id'] != null) {
		data.termRecommendId = json['term_recommend_id'] is String
				? int.tryParse(json['term_recommend_id'])
				: json['term_recommend_id'].toInt();
	}
	if (json['term_id'] != null) {
		data.termId = json['term_id'] is String
				? int.tryParse(json['term_id'])
				: json['term_id'].toInt();
	}
	if (json['name'] != null) {
		data.name = json['name'].toString();
	}
	if (json['taxonomy'] != null) {
		data.taxonomy = json['taxonomy'].toString();
	}
	if (json['type'] != null) {
		data.type = json['type'].toString();
	}
	if (json['description'] != null) {
		data.description = json['description'].toString();
	}
	if (json['parent'] != null) {
		data.parent = json['parent'].toString();
	}
	if (json['term_group'] != null) {
		data.termGroup = json['term_group'].toString();
	}
	return data;
}

Map<String, dynamic> categoryEntityToJson(CategoryEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['term_recommend_id'] = entity.termRecommendId;
	data['term_id'] = entity.termId;
	data['name'] = entity.name;
	data['taxonomy'] = entity.taxonomy;
	data['type'] = entity.type;
	data['description'] = entity.description;
	data['parent'] = entity.parent;
	data['term_group'] = entity.termGroup;
	return data;
}