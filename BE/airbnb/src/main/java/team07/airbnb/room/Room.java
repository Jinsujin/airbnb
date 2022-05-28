package team07.airbnb.room;

import javax.persistence.Column;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Index;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import team07.airbnb.address.Address;
import team07.airbnb.user.User;

@Entity
@EqualsAndHashCode(of = "id")
@Table(indexes = {@Index(columnList = "address")})
@NoArgsConstructor
public class Room {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ROOM_ID")
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "HOST_ID")
    private User host;
    private String roomName;
    @Embedded
    private Address address;
    private int price;
    private String description;
    private String composition;
    private int guestAmount;
    private int infantAmount;

}
