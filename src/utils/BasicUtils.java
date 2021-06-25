//package utils;
//
//import java.text.SimpleDateFormat;
//import java.util.ArrayList;
//import java.util.Date;
//import java.util.HashSet;
//import java.util.Iterator;
//import java.util.List;
//import java.util.Map.Entry;
//import java.util.Set;
//import java.util.TimeZone;
//
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
//import org.springframework.beans.BeanUtils;
//import org.springframework.beans.BeanWrapper;
//import org.springframework.beans.BeanWrapperImpl;
//import org.springframework.data.domain.PageRequest;
//import org.springframework.data.domain.Sort;
//
//import com.fasterxml.jackson.databind.ObjectMapper;
//import com.fasterxml.jackson.databind.SerializationFeature;
//import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
//
//import project.test.Map;
//
//public class BasicUtils {
//
//    public static final int MAX_MONGO_PAGE_SIZE = 5000;
//    public static final int ROUTE_PASS_PRODUCT_ID = 666666;
//    public static final int COMPENSATORY_FEE_PRODUCT_ID = 888888;
//
//    private static SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
//
//    private static Logger logger = LoggerFactory.getLogger(BasicUtils.class);
//
//    static {
//        formatter.setTimeZone(TimeZone.getTimeZone("UTC"));
//    }
//
//    public static String[] getNullPropertyNames (Object source, List<String> nonEmpty,List<String> skip) {
//        final BeanWrapper src = new BeanWrapperImpl(source);
//        java.beans.PropertyDescriptor[] pds = src.getPropertyDescriptors();
//
//        Set<String> emptyNames = new HashSet<>();
//        for(java.beans.PropertyDescriptor pd : pds) {
//            Object srcValue = src.getPropertyValue(pd.getName());
//            if (srcValue == null ||
//                    (skip != null &&
//                            skip.contains(pd.getName())) ||
//                    ( nonEmpty != null &&
//                            nonEmpty.contains(pd.getName()) &&
//                            !pd.getName().equals("") &&
//                            srcValue instanceof String &&
//                            srcValue.toString().equals("")
//                    )){
//                emptyNames.add(pd.getName());
//            }
//        }
//        String[] result = new String[emptyNames.size()];
//        return emptyNames.toArray(result);
//    }
//
//    public static void copyProps(Object src, Object target) {
//        copyProps(src, target, new ArrayList<>());
//    }
//
//    /**Copies props from src to target. Cant copy null props
//     List<String> nonEmpty list of props that won't be copied if they are empty ( for example you cant delete company
//     name or email of a subscription, so even if SubscriptionDTO has no mail it will be skipped
//     **/
//    public static void copyProps(Object src, Object target, List<String> nonEmpty) {
//        if(src == null){
//            target=null;
//            return;
//        }
//        BeanUtils.copyProperties(src, target, getNullPropertyNames(src, nonEmpty, new ArrayList<>()));
//    }
//
//    public static void copyPropsSkip(Object src, Object target, List<String> skip) {
//        if(src == null){
//            target=null;
//            return;
//        }
//        BeanUtils.copyProperties(src, target, getNullPropertyNames(src, new ArrayList<>(), skip));
//    }
//
//    public static void copyNonNullProps(Object src, Object target) {
//        if(src == null){
//            target=null;
//            return;
//        }
//        copyProps(src, target, new ArrayList<>());
//    }
//
//    public static int getIntFromDate(Date date, TimeZone timeZone){
//        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
//        sdf.setTimeZone(timeZone);
//        int result = Integer.valueOf(sdf.format(date).replaceAll("-",""));
//        return result;
//    }
//
//    public static PageRequest getEmptySortedPage() {
//        return getPageRequest(null, null, null);
//    }
//
//    public static PageRequest getSortedPage(Integer pageNumber, Integer pageSize, String sortingParameter, Sort.Direction sortingDirection) {
//        PageRequest page;
//        if (sortingParameter != null && !"".equals(sortingParameter)) {
//            if (sortingDirection == Sort.Direction.ASC) {
//                page = getPageRequest(pageNumber, pageSize, Sort.by(sortingParameter));
//            } else {
//                page = getPageRequest(pageNumber, pageSize, Sort.by(sortingParameter).descending());
//            }
//        } else {
//            page = getPageRequest(pageNumber, pageSize, Sort.by("createdOn").descending());
//        }
//        return page;
//    }
//
//    public static PageRequest getSortedPageWithoutRequiredParams(Integer pageNumber, Integer pageSize, String sortingParameter, Sort.Direction sortingDirection) {
//
//        if (pageNumber == null) {
//            pageNumber = 0;
//        }
//
//        if (pageSize == null) {
//            pageSize = 100;
//        }
//
//        return getSortedPage(pageNumber, pageSize, sortingParameter, sortingDirection);
//    }
//
//    // NOTE: seems like it won't be easy to remove this method before all controllers migrate
//    // from ExampleCreatorService to QueryCreatorService
//    /**
//     * Use getFiltersContainsAndExactMap instead.
//     */
////    @Deprecated
////    public static Map<String, String> get_ONLY_CONTAINS_Filters(Map<String, String> requestParams) {
////
////        return getFiltersContainsAndExactMap(requestParams).get(FilterTypeEnum.CONTAINS);
////    }
//
////    public static Map<FilterTypeEnum, Map<String, String>> getFiltersContainsAndExactMap(Map<String, String> requestParams) {
////
////        Map<String, String> exactMatch = new HashMap<>();
////        Map<String, String> containsMatch = new HashMap<>();
////
////        for (Map.Entry<String, String> entry: requestParams.entrySet()) {
////            String fieldName = entry.getKey();
////            String fieldValue = entry.getValue();
////
////            if (fieldName.startsWith("f_")) {
////                containsMatch.put(fieldName.substring("f_".length()), fieldValue);
////            }
////
////            if (fieldName.startsWith("fe_")) {
////                exactMatch.put(fieldName.substring("fe_".length()), fieldValue);
////            }
////        }
////
////        return new HashMap<FilterTypeEnum, Map<String, String>>() {{
////            put(FilterTypeEnum.CONTAINS, containsMatch);
////            put(FilterTypeEnum.EXACT, exactMatch);
////        }};
////    }
//
//    public static String withUrlParams(String url, Map params) {
//        Set<String> urlParts = new HashSet<>();
//
//        for (Entry<String, Object> entry: params.entrySet()) {
//            if (entry.getValue() == null) {
//                continue;
//            }
//
//            urlParts.add(entry.getKey()+"="+entry.getValue());
//        }
//
//        if (url.isEmpty()) {
//            return url;
//        }
//
//        url += "?";
//
//        Iterator<String> it = urlParts.iterator();
//
//        String first = it.next();
//
//        url += first;
//
//        while (it.hasNext()) {
//            url += "&"+it.next();
//        }
//
//        return url;
//    }
//
//    private static PageRequest getPageRequest(Integer pageNumber, Integer pageSize, Sort sort) {
//        if (pageNumber == null || pageSize == null || pageSize < 1) {
//            return PageRequest.of(0, MAX_MONGO_PAGE_SIZE);
//        }
//
//        return PageRequest.of(pageNumber, pageSize, sort);
//    }
//
//
////    public static String getSingleProductPrice(Integer kapschProductId, ProductsResponse productsResponse) {
////        if (kapschProductId != null && (kapschProductId.equals(ROUTE_PASS_PRODUCT_ID) || kapschProductId.equals(COMPENSATORY_FEE_PRODUCT_ID))) {
////            return "";
////        } else {
////            return productsResponse.getPrice().getAmount().toString();
////        }
////    }
//
//    public static String getProductName(Integer kapschProductId, String categoryDescriptionText, String vehicleType, String emissionClass, String validityTypeText, String productTypeLabel) {
//
//        if (kapschProductId != null && (kapschProductId.equals(ROUTE_PASS_PRODUCT_ID) || kapschProductId.equals(COMPENSATORY_FEE_PRODUCT_ID))) {
//            return " : " +productTypeLabel;
//        } else {
//            return " : еВинетка "
//                    + (categoryDescriptionText != null ? categoryDescriptionText + " " : "")
//                    + (vehicleType != null ? vehicleType + " " : "")
//                    + (emissionClass != null ? emissionClass + " " : "")
//                    + (validityTypeText != null ? validityTypeText : "");
//        }
//    }
//
//    public static String writeValueAsString(Object object) {
//        ObjectMapper mapper = new ObjectMapper();
//        mapper.setDateFormat(new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss"));
//        mapper.registerModule(new JavaTimeModule());
//        mapper.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
//        try {
//            return mapper.writeValueAsString(object);
//        } catch (Exception e) {
//            return null;
//        }
//    }
//}