//package conditions;
//
//import static iute.crm.util.Constants.SMS_STATUS_DELIVERED;
//import static iute.crm.util.Constants.SMS_STATUS_FAILED;
//import static iute.crm.util.Constants.SMS_STATUS_SENT;
//import static java.util.Arrays.asList;
//import static org.junit.Assert.assertEquals;
//import static org.junit.Assert.assertThat;
//import static org.mockito.ArgumentMatchers.any;
//import static org.mockito.Mockito.doNothing;
//import static org.mockito.Mockito.when;
//
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//
//import org.hamcrest.Matchers;
//import org.joda.time.DateTime;
//import org.junit.Test;
//import org.junit.runner.RunWith;
//import org.mockito.Mock;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.context.annotation.ImportResource;
////import org.springframework.context.annotation.DependsOn;
//import org.springframework.test.context.ContextConfiguration;
//import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
//import org.springframework.test.util.JsonExpectationsHelper;
//
//import iute.crm.config.DatasourceConfiguration;
//import iute.crm.config.Les2Configuration;
//import iute.crm.dao.impl.CountryConfigurationDaoImpl;
//
//@Configuration
////@DependsOn("les2Configuration")
//@RunWith(SpringJUnit4ClassRunner.class)
//@ContextConfiguration(classes = { SmsMoldovaService.class, CountryConfigurationDaoImpl.class, DatasourceConfiguration.class,
//        Les2Configuration.class
//        })
//@ImportResource("classpath:configuration/spring-app-context.xml")
//public class SmsMoldovaServiceTest {
//
//    @Mock
//    protected SmsMoldovaService service;
//    
//    @Test
//    public void createMessage() throws Exception {
//        when(service.createMessage(any(SmsMessage.class))).thenReturn("{\"DNIS\":\"37379109942\",\"ANI\":\"\",\"Enc\":\"UTF8\",\"BMess\":\"1234567890\"}");
//        
//        SmsMessage message = new SmsMessage();
//        message.setSendToNumber("37379109942");
//        message.setText("1234567890");
//
//        String content  = service.createMessage(message);
//        String expected = "{\"DNIS\":\"37379109942\",\"ANI\":\"\",\"Enc\":\"UTF8\",\"BMess\":\"1234567890\"}";
//        new JsonExpectationsHelper().assertJsonEqual(expected, content);
//    }
//
//    @Test
//    public void updateStatuses() {
//        doNothing().when(service).updateStatuses(any(List.class), any(Map.class));
//       
//        SmsMessage withoutError = new SmsMessage();
//        withoutError.setId(1);
//        SmsMessage withError = new SmsMessage();
//        withError.setId(2);
//        SmsMessage withTechnicalError = new SmsMessage();
//        withTechnicalError.setId(3);
//
//        Map<Integer, String> responses = new HashMap<>();
//        responses.put(1, "{\"RStatus\":0,\"NRID\":\"id-from-server\"}");
//        responses.put(2, "{\"RStatus\":1,\"ErrorMessage\":\"Invalid PID\"}");
//        responses.put(3, "{\"RStatus\":100,\"ErrorMessage\":\"technical error\"}");
//                
//        withoutError.setStatus(SMS_STATUS_SENT);
//        withoutError.setMessageId("id-from-server");
//        withError.setStatus(SMS_STATUS_FAILED);
//        withError.setComment("Invalid PID");
//        withTechnicalError.setStatus(SMS_STATUS_FAILED);
//        withTechnicalError.setComment("technical error");
//
//        service.updateStatuses(asList(withoutError, withError, withTechnicalError), responses);
//        
//        assertEquals(withoutError.getStatus(),SMS_STATUS_SENT);
//        assertEquals(withoutError.getMessageId(),"id-from-server");
//        assertEquals(withError.getStatus(),SMS_STATUS_FAILED);
//        assertEquals(withError.getComment(),"Invalid PID");
//        assertEquals(withTechnicalError.getStatus(),SMS_STATUS_FAILED);
//        assertEquals(withTechnicalError.getComment(),"technical error");
//    }
//
//    @Test
//    public void updateStatus_without_error() {
//        doNothing().when(service).updateStatus(any(SmsMessage.class), any(Map.class));
//        
//        SmsMessage message = new SmsMessage();
//
//        Map<String, Object> response = new HashMap<>();
//        response.put("DStatus", 0);
//        response.put("DDate", "2017-06-18 13:34:09");
//        response.put("DMessage", "Delivered");
//
//        service.updateStatus(message, response);
//        message.setStatus(SMS_STATUS_DELIVERED);
//        message.setComment("Delivered");
//        message.setDelivered(DateTime.parse("2017-06-18T13:34:09").toDate());
//
//        assertEquals(message.getStatus(), SMS_STATUS_DELIVERED);
//        assertEquals(message.getComment(),"Delivered");
//        assertThat(message.getDelivered(),Matchers.comparesEqualTo(DateTime.parse("2017-06-18T13:34:09").toDate()));
//    }
//
//    @Test
//    public void updateStatus_with_error() {
//        doNothing().when(service).updateStatus(any(SmsMessage.class), any(Map.class));
//        
//        SmsMessage message = new SmsMessage();
//
//        Map<String, Object> response = new HashMap<>();
//        response.put("DStatus", 1);
//        response.put("DMessage", "We have problems");
//        
//        message.setStatus(SMS_STATUS_FAILED);
//        message.setComment("We have problems");
//        service.updateStatus(message, response);
//
//        assertEquals(message.getStatus(),SMS_STATUS_FAILED);
//        assertEquals(message.getComment(),"We have problems");
//    }
//}
